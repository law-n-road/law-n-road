// src/libs/axios-auth.js
import axios from 'axios'
import { useRouter } from 'vue-router'
import { getRouter } from './routerService'

export const getValidToken = async () => {
    let token = localStorage.getItem('token')
    let expired = false

    if (token) {
        try {
            const decoded = jwt_decode(token)
            const now = Math.floor(Date.now() / 1000)
            // 60초 이내 만료될 예정이면 미리 갱신
            if (decoded.exp && decoded.exp - now < 60) expired = true
        } catch {
            expired = true
        }
    } else {
        expired = true
    }

    if (expired) {
        token = await refreshAccessToken()
        if (!token) return null
    }
    return token
}

export const refreshAccessToken = async () => {
    const router2 = getRouter()
    // const router = useRouter() // Composition API 훅 내부에서 호출
    const userNo = localStorage.getItem('no')
    if (!userNo) {
        // alert('죄송합니다! 다시 로그인해주세요')
        localStorage.clear()
        // router2.push('/login')
        return null
    }

    try {
        const res = await axios.post('/api/refresh', { no: Number(userNo) })
        const newAccessToken = res.data.accessToken
        localStorage.setItem('token', newAccessToken)
        axios.defaults.headers.common['Authorization'] = `Bearer ${newAccessToken}`
        return newAccessToken
    } catch (err) {
        console.error('❌ 액세스 토큰 재발급 실패:', err)
        localStorage.clear()
        router2.push('/login')
        return null
    }
}


export const makeApiRequest = async (config) => {
    let token = localStorage.getItem('token')
    if (!token) {
        token = await refreshAccessToken()
        if (!token) return null
    }

    const isMultipart = config.data instanceof FormData

    try {
        return await axios({
            ...config,
            headers: {
                ...(config.headers || {}),
                'Authorization': `Bearer ${token}`,
                'Content-Type': 'application/json'
                // ...(isMultipart ? {} : { 'Content-Type': 'application/json' }) // form 데이터면 생략, 아니면 추가
            },
            timeout: 10000
        })
    } catch (error) {
        if (error.response?.status === 401 || error.response?.status === 403) {
            const newToken = await refreshAccessToken()
            if (!newToken) return null

            return await axios({
                ...config,
                headers: {
                    ...(config.headers || {}),
                    'Authorization': `Bearer ${newToken}`,
                    'Content-Type': 'application/json'
                    // ...(isMultipart ? {} : { 'Content-Type': 'application/json' })
                },
                timeout: 10000
            })
        }

        throw error
    }


}
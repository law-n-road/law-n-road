import { defineStore } from 'pinia'
import {getValidToken, makeApiRequest} from '@/libs/axios-auth.js'

export const useLawyerStore = defineStore('lawyer', {
    state: () => ({
        lawyerInfo: 0,
        name: '',
        profileImagePath: '',
        fetched: false
    }),
    getters: {
        getLawyerNo(state) {
            return state.lawyerInfo?.data?.lawyerNo ?? null
        },
        getName(state) {
            return state.lawyerInfo?.data?.name ?? ''
        },
        getProfileImage(state) {
            return state.lawyerInfo?.data?.profileImagePath ?? ''
        }
    },

    actions: {
        reset() {
            this.lawyerInfo = 0
            this.name = ''
            this.profileImagePath = ''
            this.fetched = false
            this.fetchTried = false
            this.fetchSucceeded = false
        },

        // 동일한 값에 대해 반복적으로 조회되는 것을 피하기 위함
        async fetchLawyerInfo(no) {
            if (this.fetchTried) return
            this.fetchTried = true

            try {
                const token = await getValidToken()
                if (!token) {
                    alert('로그인이 필요합니다.')
                    return
                }

                const res = await makeApiRequest({
                    method: 'get',
                    url: `/api/lawyer/info/${no}`
                })

                if (res) {
                    this.lawyerInfo = res.data
                    this.fetchSucceeded = true
                } else {
                    throw new Error('makeApiRequest 반환값이 null임')
                }
            } catch (e) {
                console.warn('변호사 정보 조회 실패. 나중에 다시 시도 필요.', e)
                this.fetchTried = false
            }
        }


    }
})
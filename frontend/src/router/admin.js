export default [
    // {
    //     path: '/admin',
    //     name: 'Admin',
    //     component: () => import('@/views/admin/DashboardView.vue')
    // },

    {
        path: '/admin',
        name: 'MemberManagement',
        component: () => import('@/views/admin/MemberManagementView.vue')
    },

    {
        path: '/admin/ads',
        name: 'AdManagement',
        component: () => import('@/views/admin/AdManagementView.vue')
    },
    // 예시: router/admin.js 또는 router/index.js
    {
        path: '/admin/lawyer',
        name: 'LawyerManagement',
        component: () => import('@/views/admin/LawyerManagementView.vue')
    },
    {
        path: '/admin/report_lawyer',
        name: 'ReportLawyerManagement',
        component: () => import('@/views/admin/AdminReportView.vue') // 이 컴포넌트 추가 필요
    },
    {
        path: '/admin/report_client',
        name: 'ReportClientManagement',
        component: () => import('@/views/admin/AdminReportClientView.vue') // 이 컴포넌트 추가 필요
    },


]
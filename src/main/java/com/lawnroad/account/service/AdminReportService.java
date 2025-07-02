package com.lawnroad.account.service;

import com.lawnroad.account.dto.BroadcastReportConfirmDTO;
import com.lawnroad.account.dto.ChatReportConfirmDto;
import com.lawnroad.account.mapper.AdminReportMapper;
import com.lawnroad.account.mapper.LawyerMapper;
import com.lawnroad.advertisement.mapper.AdMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminReportService {

    private final AdminReportMapper adminReportMapper;
    private final AdMapper adMapper;

    public List<BroadcastReportConfirmDTO> getUnpenalizedReports() {
        System.out.println("getUnpenalizedReports");
        return adminReportMapper.selectUnpenalizedReports();
    }


    @Transactional
    public void applyPenalty(Long broadcastNo) {
        // 방송번호로 변호사 포인트 차감
        adminReportMapper.deductLawyerPoint(broadcastNo);

        // 해당 신고건 status = 1로 처리
        adminReportMapper.markReportAsPenalized(broadcastNo);
    }
    @Transactional
    public void applyPenaltyClient(Long userNo) {
        adminReportMapper.applyPenaltyClient_M(userNo);
        adminReportMapper.applyPenaltyClient_M1(userNo);
    }


    public List<ChatReportConfirmDto> getPenalizedChatReports() {
        System.out.println("getPenalizedChatReports");
        return adminReportMapper.selectPenalizedChatReports();
    }

    public void penalizeClientByUserNo(Long userNo) {
        System.out.println("의뢰인 패널티 부여");
        LocalDate tomorrow = LocalDate.now();
        adminReportMapper.updateClientPenalty(userNo, tomorrow);
    }


    public void penalizeReport(Long reportNo) {
        int updated = adminReportMapper.updateReportStatus(reportNo);
        if (updated == 0) {
            throw new IllegalArgumentException("해당 신고번호의 신고가 존재하지 않거나 이미 처리되었습니다.");
        }
    }


    @Scheduled(cron = "0 5 0 * * *")  // 매일 새벽 3시
    public void autoReleaseClientStop() {
        adminReportMapper.releaseClientStop();
        System.out.println("✅ 자동 정지 해제 완료됨");
    }

    @Scheduled(cron = "0 18 16 * * *")  // 매일 오후 4시 10분
    public void autoReleaseClientStop_ad() {
        adMapper.releaseClientStop();
        System.out.println("✅ 광고 자동 해제 완료됨");
    }

}



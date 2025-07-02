package com.lawnroad.admin.service;

import com.lawnroad.admin.dto.AdPurchaseDto;
import com.lawnroad.admin.dto.AdPurchaseListResponseDto;
import com.lawnroad.admin.dto.AdPurchaseSearchConditionDto;
import com.lawnroad.admin.mapper.AdminPageMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminService {
  private final AdminPageMapper mapper;
  
  public AdPurchaseListResponseDto getAdPurchases(AdPurchaseSearchConditionDto cond) {
    List<AdPurchaseDto> items = mapper.selectAdPurchases(cond);
    int totalCount = mapper.countAdPurchases(cond);
    int totalPages = (int) Math.ceil((double) totalCount / cond.getLimit());
    
    AdPurchaseListResponseDto resp = new AdPurchaseListResponseDto();
    resp.setItems(items);
    resp.setTotalCount(totalCount);
    resp.setTotalPages(totalPages);
    return resp;
  }
  
  @Transactional
  public void updateApprovalStatus(Long adNo, String status) {
    mapper.updateApprovalStatus(adNo, status);
  }
  
  /**
   * 매일 00:00에 실행 (Asia/Seoul 기준).
   * start_date가 오늘이고, 승인된 광고만 활성화(ad_status = 1)
   */
  @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Seoul")
  public void activateTodayAds() {
    int updated = mapper.activateTodayAds();
  }
}

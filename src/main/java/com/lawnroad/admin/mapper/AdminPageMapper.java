package com.lawnroad.admin.mapper;

import com.lawnroad.admin.dto.AdPurchaseDto;
import com.lawnroad.admin.dto.AdPurchaseSearchConditionDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface AdminPageMapper {
  // 광고 관리 조회 등
  List<AdPurchaseDto> selectAdPurchases(AdPurchaseSearchConditionDto cond);
  int                 countAdPurchases(AdPurchaseSearchConditionDto cond);
  
  // 광고 승인 반려 관련
  void updateApprovalStatus(
      @Param("no") Long adNo,
      @Param("status") String approvalStatus
  );
  
  /**
   * start_date가 오늘이고 승인(APPROVED)된 광고의 ad_status를 1로 설정
   */
  @Update("""
    UPDATE ad_purchase
    SET ad_status = 1
    WHERE DATE(start_date) = CURDATE()
      AND approval_status = 'APPROVED'
  """)
  int activateTodayAds();
}

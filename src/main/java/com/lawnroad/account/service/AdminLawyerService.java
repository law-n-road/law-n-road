package com.lawnroad.account.service;


import com.lawnroad.account.dto.LawyerDTO;
import com.lawnroad.account.mapper.LawyerMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AdminLawyerService {

    private final LawyerMapper lawyerMapper;

//    public List<LawyerDTO> getLawyerList(Map<String, Object> param) {
//        return lawyerMapper.selectLawyerList(param);
//    }

//    public List<LawyerDTO> getLawyerList(String status, String keyword, int offset, int limit) {
//        return lawyerMapper.selectLawyerList(status, keyword, offset, limit);
//    }

    public List<LawyerDTO> getAllLawyers() {
        return lawyerMapper.selectAllLawyers();
    }

    public void approveLawyer(Long no) {
        lawyerMapper.updateStatus(no, "APPROVED_JOIN");
    }



}

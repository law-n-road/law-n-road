package com.lawnroad.account.service;


import com.lawnroad.account.dto.ClientSignupRequest;
import com.lawnroad.account.dto.LawyerSignupRequest;
import com.lawnroad.account.entity.ClientEntity;
import com.lawnroad.account.entity.LawyerEntity;
import com.lawnroad.account.entity.UserEntity;
import com.lawnroad.account.mapper.ClientMapper;
import com.lawnroad.account.mapper.LawyerMapper;
import com.lawnroad.account.mapper.UserMapper;
import com.lawnroad.reservation.service.TimeSlotService;
import com.lawnroad.common.util.NcpObjectStorageUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import static java.time.LocalDate.now;

@Service
public class LawyerService {

    @Autowired


    private LawyerMapper lawyerMapper;
    private UserMapper userMapper;
    private PasswordEncoder passwordEncoder;
    private TimeSlotService timeSlotService;
    private final NcpObjectStorageUtil ncpObjectStorageUtil;

    public LawyerService(UserMapper userMapper, LawyerMapper lawyerMapper, PasswordEncoder passwordEncoder, TimeSlotService timeSlotService
    ,NcpObjectStorageUtil ncpObjectStorageUtil) {
        this.userMapper = userMapper;
        this.lawyerMapper = lawyerMapper;
        this.passwordEncoder = passwordEncoder;
        this.timeSlotService = timeSlotService;
        this.ncpObjectStorageUtil = ncpObjectStorageUtil;


    }


    public boolean isLawyerAvailable(String lawyerId) {
        int count1 = lawyerMapper.countByLawyerId1(lawyerId);
        int count2 = lawyerMapper.countByLawyerId2(lawyerId);
        return count1 + count2 == 0; // 0 이면 사용 가능, true 반환
    }

    @Transactional
    public void registerLawyer(LawyerSignupRequest request,
                               MultipartFile profileImage,
                               MultipartFile idCardFront,
                               MultipartFile idCardBack) {
        // 1. user 테이블 삽입
        UserEntity user = new UserEntity();
        user.setType("LAWYER");
        userMapper.insertUser(user);

        // 2. 이미지 파일 저장
        String profileImageUrl = ncpObjectStorageUtil.save(profileImage, "uploads/lawyers/" + user.getNo() + "/profile", null);
        String cardFrontUrl = ncpObjectStorageUtil.save(idCardFront, "uploads/lawyers/" + user.getNo() + "/card/front", null);
        String cardBackUrl = ncpObjectStorageUtil.save(idCardBack, "uploads/lawyers/" + user.getNo() + "/card/back", null);

        // 3. lawyer 테이블 삽입
        LawyerEntity lawyer = new LawyerEntity();
        lawyer.setNo(user.getNo());
        lawyer.setLawyerId(request.getLawyerId());
        lawyer.setPwHash(passwordEncoder.encode(request.getPassword()));
        lawyer.setEmail(request.getEmail());
        lawyer.setName(request.getFullName());
        lawyer.setPhone(request.getPhone());
        lawyer.setOfficeName(request.getOfficeName());
        lawyer.setOfficeNumber(request.getOfficeNumber());
        lawyer.setZipcode(request.getZipcode());
        lawyer.setRoadAddress(request.getRoadAddress());
        lawyer.setLandAddress(request.getLandAddress());
        lawyer.setDetailAddress(request.getDetailAddress());
        lawyer.setConsent(request.getConsent());
        lawyer.setPoint(0);
        lawyer.setConsultPrice(30000);
        lawyer.setStatus("REJECTED_JOIN");

        // ✅ 이미지 URL 저장
        lawyer.setProfile(profileImageUrl);
        lawyer.setCardFront(cardFrontUrl);
        lawyer.setCardBack(cardBackUrl);

        lawyer.setLawyerIntro(request.getLawyerIntro());
        lawyer.setIntroDetail(request.getIntroDetail());
        lawyerMapper.insertLawyer(lawyer);

        // 회원가입을 하게 된 변호사의 일주일간의 주간 슬롯 생성
        timeSlotService.generateWeeklyTimeSlots(user.getNo(),now());
    }




//    public boolean isEmailAvailable(String email) {
//        int count = clientMapper.countByEmail(email);
//        return count == 0; // 0이면 사용 가능
//    }
//
//
//    public ClientEntity login(String clientId, String rawPassword) {
//        ClientEntity client = clientMapper.findByClientId(clientId);
//        if (client == null) {
//            throw new IllegalArgumentException("아이디 존재하지 않음");
//        }
//
//        // ✅ 여기에 디버깅 로그 삽입
//        System.out.println("입력 비번: " + rawPassword);
//        System.out.println("DB 비번: " + client.getPwHash());
//        System.out.println("일치 여부: " + passwordEncoder.matches(rawPassword, client.getPwHash()));
//
//        if (!passwordEncoder.matches(rawPassword, client.getPwHash())) {
//            throw new IllegalArgumentException("비밀번호 불일치");
//
//        }
//
//
//        return client;
//    }

    public LawyerEntity login(String lawyerId, String rawPassword) {
        LawyerEntity lawyer = lawyerMapper.findByLawyerId(lawyerId);
        System.out.println("🟡 lawyerService.login() 진입, ID: " + lawyerId);
        if (lawyer == null) {
            System.out.println("아이디 존재 X");
            throw new IllegalArgumentException("아이디 존재하지 않음");
        }

        if (!passwordEncoder.matches(rawPassword, lawyer.getPwHash())) {
            System.out.println("비번 불일치");
            throw new IllegalArgumentException("비밀번호 불일치");

        }

        return lawyer;
    }

    public String findLawyerId(String fullName, String email) {
        return lawyerMapper.findLawyerId(fullName, email);
    }



    public boolean resetPassword(String lawyerId, String email, String fullName, String newPassword) {
        LawyerEntity lawyer = lawyerMapper.findByLawyerId(lawyerId);

        System.out.println(lawyer);

        if (lawyer == null || !lawyer.getEmail().equals(email) || !lawyer.getName().equals(fullName)) {
            return false;
        }

        String hashed = passwordEncoder.encode(newPassword);
        lawyerMapper.updatePassword(lawyerId, hashed);
        return true;
    }

    public void updateLawyerInfo(String lawyerId,
                                 String officeNumber,
                                 String phone,
                                 String detailAddress,
                                 String zipcode,
                                 String roadAddress,
                                 String landAddress) {
        lawyerMapper.updateLawyerInfo(lawyerId, officeNumber, phone, detailAddress, zipcode, roadAddress, landAddress);
    }

    public void lawyer_withdraw(Long userNo) {
        int result = lawyerMapper.markAsWithdrawn(userNo);
        if (result == 0) {
            throw new IllegalArgumentException("해당 변호사를 찾을 수 없거나 이미 탈퇴 처리됨");
        }
    }

}

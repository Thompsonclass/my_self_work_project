package com.capstone.cap.config;


import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;


/**
 * RestTemplate을 Bean으로 등록해 DI 가능하게 함
 */
@Configuration
public class GPTConfig {

	 @Bean
	    public RestTemplate restTemplate() {
	        return new RestTemplate();
	    }

}
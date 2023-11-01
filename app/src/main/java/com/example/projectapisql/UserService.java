package com.example.projectapisql;

import java.util.List;

import retrofit2.Call;
import retrofit2.http.GET;

public interface UserService {
    @GET("GetAllUsers")
    Call<List<User>> getUsers();
}
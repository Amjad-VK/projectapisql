package com.example.projectapisql;
import retrofit2.Response;


import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.os.Bundle;

import java.util.List;

public class admin_viewsalesman extends AppCompatActivity {
    private RecyclerView recyclerView;
    private UserAdapter userAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin_viewsalesman);
        recyclerView = findViewById(R.id.recyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));

        // Assuming you have received the list of users in response.body() from your Retrofit call
        List<User> userList = response.body();

        userAdapter = new UserAdapter(userList, this);
        recyclerView.setAdapter(userAdapter);
    }
}
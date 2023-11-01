package com.example.projectapisql;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class admin_home extends AppCompatActivity {
    private Button approveUserButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_admin_home);
        approveUserButton = findViewById(R.id.approveButton);

        approveUserButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Handle the "Approve User" button click event
                // Navigate to the "View Salesman" page
                Intent intent = new Intent(admin_home.this, admin_viewsalesman.class);
                startActivity(intent);
            }
        });
    }
}
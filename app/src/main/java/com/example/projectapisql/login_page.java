package com.example.projectapisql;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class login_page extends AppCompatActivity {
    private EditText usernameEditText;
    private EditText passwordEditText;
    private Button loginButton;
    private TextView registerLink;

    @SuppressLint("MissingInflatedId")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login_page);
        usernameEditText = findViewById(R.id.username);
        passwordEditText = findViewById(R.id.password);
        loginButton = findViewById(R.id.login);
        registerLink = findViewById(R.id.registerLink);
        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Get the entered username and password
                String enteredUsername = usernameEditText.getText().toString();
                String enteredPassword = passwordEditText.getText().toString();

                // Check if the username and password match the criteria
                if (enteredUsername.equals("admin") && enteredPassword.equals("123")) {
                    // Login successful, navigate to the admin home page
                    Intent intent = new Intent(login_page.this, admin_home.class);
                    startActivity(intent);
                } else {
                    // Login failed, show an error message
                    Toast.makeText(login_page.this, "Invalid username or password", Toast.LENGTH_SHORT).show();
                }
            }
        });
        registerLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Handle the "Don't have an account" click event
                // Navigate to the user registration page
                Intent intent = new Intent(login_page.this, user_registration.class);
                startActivity(intent);
            }
        });
    }

    }

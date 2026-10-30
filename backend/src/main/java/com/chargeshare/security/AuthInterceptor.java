package com.chargeshare.security;

import com.chargeshare.repository.UserAccountRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {
    private final SessionService sessions;
    private final UserAccountRepository users;

    public AuthInterceptor(SessionService sessions, UserAccountRepository users) {
        this.sessions = sessions;
        this.users = users;
    }

    @Override
    public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler) {
        String path = req.getRequestURI();
        if (path.equals("/api/auth/login") || path.equals("/api/auth/register")
                || path.equals("/error") || "OPTIONS".equalsIgnoreCase(req.getMethod())) {
            return true;
        }
        String header = req.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return false;
        }
        String token = header.substring(7).trim();
        AuthSession session = sessions.get(token);
        if (session == null) {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return false;
        }
        var account = users.findById(session.userId()).orElse(null);
        if (account == null || !account.isEnabled()) {
            sessions.revoke(token);
            res.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return false;
        }
        CurrentUser.set(session);
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest req, HttpServletResponse res, Object handler, Exception ex) {
        CurrentUser.clear();
    }
}

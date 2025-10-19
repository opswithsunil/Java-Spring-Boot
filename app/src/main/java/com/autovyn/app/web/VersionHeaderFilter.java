package com.autovyn.app.web;

import org.springframework.boot.info.BuildProperties;
import org.springframework.stereotype.Component;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class VersionHeaderFilter implements Filter {
    private final BuildProperties buildProperties;

    public VersionHeaderFilter(BuildProperties buildProperties) {
        this.buildProperties = buildProperties;
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        if (response instanceof HttpServletResponse resp) {
            String version = buildProperties != null ? buildProperties.getVersion() : "unknown";
            resp.setHeader("X-App-Version", version);
        }
        chain.doFilter(request, response);
    }
}



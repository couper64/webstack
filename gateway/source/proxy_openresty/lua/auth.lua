local openidc = require("resty.openidc")

local _M = {}

function _M.authenticate()

    local l_issuer_public = os.getenv("OIDC_ISSUER_PUBLIC") -- "https://localhost:9990/iam/realms/myrealm"
    local l_issuer_internal = os.getenv("OIDC_ISSUER_INTERNAL") -- "http://keycloak:8080/iam/realms/myrealm"
    local l_redirect_uri = os.getenv("OIDC_REDIRECT_URI") -- "https://localhost:9990/redirect_uri"

    local opts = {
        -- Replace the discovery string with a table
        discovery = {
            issuer = l_issuer_public,
            
            -- Must use internal issuer.
            token_endpoint = l_issuer_internal .. "/protocol/openid-connect/token",
            authorization_endpoint = l_issuer_public .. "/protocol/openid-connect/auth",
            jwks_uri = l_issuer_internal .. "/protocol/openid-connect/certs",
            userinfo_endpoint = l_issuer_internal .. "/protocol/openid-connect/userinfo",
            introspection_endpoint = l_issuer_internal .. "/protocol/openid-connect/token/introspect",
        },

        client_id = os.getenv("OIDC_CLIENT_ID"), -- "my-client",
        client_secret = os.getenv("OIDC_CLIENT_SECRET"),
        redirect_uri = l_redirect_uri,
        logout_path = "/logout",
        ssl_verify = "no", -- Set to "yes" for production with valid CA certs.
        
        -- Optional: Force re-authentication if the session is older than 1 hour.
        session_contents = {id_token=true, access_token=true},
        
        -- Ensure the cookie is valid for your path.
        session_cookie_path = "/",
    }

    local session_opts = {
        secret = "a_very_long_and_secure_random_st", -- REQUIRED in 2026

        -- If you are testing on HTTP, set this to false. 
        -- If using HTTPS (port 9990), set to true.
        cookie_secure = true,

        -- In local dev without proper domain names, 'lax' is safer.
        cookie_same_site = "Lax"
    }

    -- Perform the OIDC authentication
    local res, err = openidc.authenticate(opts, nil, nil, session_opts)

    if err then
        ngx.status = 500
        ngx.say("Authentication Error: " .. err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    -- If successful, inject headers for the upstream backend
    ngx.req.set_header("X-User-Sub", res.id_token.sub)
    ngx.req.set_header("X-User-Preferred-Username", res.id_token.preferred_username)
end

return _M
# Nomad OIDC Action

Get short-live Nomad Token through OIDC Authentication on GitHub Action.

## Inputs
- nomad_addr: Nomad HTTP address (e.g., https://nomad.example.com:4646). Required.
- region: Optional Nomad region.
- namespace: Optional Nomad namespace.
- tls_skip_verify: Skip TLS verification (insecure). Default: false.
- ca_pem: Optional CA PEM content; if provided, written to a temp file and used with curl --cacert.
- client_cert: Optional client certificate content (PEM); if provided, written to a temp file and used with curl --cert.
- client_key: Optional client private key content (PEM); if provided, written to a temp file and used with curl --key.
- oidc_audience: OIDC audience for token request. Default: nomad.example.com.
- oidc_auth_method_name: The name of the ACL authentication method to use. Default: github.
- debug: Enable debug output for OIDC authentication responses. Default: false.

## Outputs
- nomad_token: Short-live Nomad Token.

## Usage
Example workflow step to use Nomad OIDC:

```yaml
jobs:
  nomad-operation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Get Nomad Token
        id: auth
        uses: habibimustafa/nomad-oidc@v0.0.1
        with:
          nomad_addr: ${{ secrets.NOMAD_ADDR }}
          region: ""
          namespace: "default"
      - name: Result
        run: |
          echo "Nomad Token: ${{ steps.auth.outputs.nomad_token }}"
```

**Requirements for OIDC authentication:**
- The workflow must have `id-token: write` permission
- Nomad must be configured with the OIDC authentication method
- The `oidc_audience` should match your Nomad OIDC configuration

**Troubleshooting OIDC authentication:**
- Set `debug: true` to see the raw Nomad authentication response
- This helps diagnose jq parsing failures and authentication errors

**Encryption**
- Set `encryption_password: ${{ secrets.ENCRYPTION_PASSWORD }}` to encrypt Nomad Token
- Decrypt the Nomad Token using OpenSSL like below: 
```yaml
- name: Decrypt nomad token
  id: decrypt-token
  shell: bash
  run: |
    NOMAD_TOKEN=${{ needs.oidc-auth.outputs.nomad-token }};
    BINARY_NOMAD_TOKEN=$(printf %s "$NOMAD_TOKEN" | base64 -d);
    DECRYPTED_NOMAD_TOKEN=$(
        printf %s "${BINARY_NOMAD_TOKEN}" |
        openssl enc -aes-256-cbc -pbkdf2 -md sha256 -d -salt -pass pass:"${{ secrets.ENCRYPTION_PASSWORD }}"
    );
    echo "nomad-token=$DECRYPTED_NOMAD_TOKEN" >> $GITHUB_OUTPUT
```

**TLS Options**
- Set `tls_skip_verify: true` to bypass verification (not recommended for production).
- Provide a CA certificate via `ca_pem: ${{ secrets.NOMAD_CA_PEM }}` to trust a custom CA.

## Notes
- Requires `curl` and `jq` (available on ubuntu-latest runners).
- Requires `openssl` and `base64` for encryption process.

## References
- https://www.hashicorp.com/en/blog/nomad-jwt-auth-with-github-actions
- https://developer.hashicorp.com/nomad/api-docs/acl/login

## License
This action is provided as-is under [MIT License](LICENSE).

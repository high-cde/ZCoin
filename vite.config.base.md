# GitHub Pages Config Note

When deploying to GitHub Pages under a repo path (e.g. `https://high-cde.github.io/Highcoin/`),
set `base` in `vite.config.ts` to match the repo name:

```ts
export default defineConfig({
  base: '/Highcoin/',
  // ...rest of config
})
```

For a custom domain (CNAME), set `base: '/'`.

The GitHub Actions workflow in `.github/workflows/deploy.yml` handles the automated build and deploy on every push to `main`.

## Required GitHub Secrets

Set these in your repo Settings > Secrets > Actions:

- `VITE_HERCULES_OIDC_AUTHORITY`
- `VITE_HERCULES_OIDC_CLIENT_ID`  
- `VITE_CONVEX_URL`

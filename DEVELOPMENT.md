# Development

Source of [misli.mmatokovic.dev](https://misli.mmatokovic.dev), a Hugo site styled with Tailwind CSS v4 and deployed on Netlify.
`README.adoc` is the GitHub profile README, so project notes live here.

## Run locally

```sh
git submodule update --init   # fetch the sleeve theme
pnpm install                  # Tailwind CSS, Alpine.js, Turbo
hugo server                   # http://localhost:1313
```

Versions are pinned in one place each: Hugo in `netlify.toml` (`HUGO_VERSION`), Node in `.node-version`, pnpm in `package.json` (`packageManager`).

Croatian is the default language and lives at the site root (`content/hr`); English is under `/en/` (`content/en`).

## What only works on the deployed site

- **Contact form** — handled by Netlify Forms (`data-netlify`), so submitting from `hugo server` does nothing.
- **Google Analytics and the cookie banner** — rendered only in production builds (`hugo.IsProduction`), and gtag.js loads only after the visitor accepts.
- **Headers and redirects** — security headers, the CSP and caching live in `netlify.toml`; redirects in `static/_redirects`.

Deploy previews and branch deploys build with `HUGO_ENVIRONMENT=preview`, which adds `<meta name="robots" content="noindex">`.

## Theme

The layouts, CSS and JS come from [sleeve](https://github.com/mmatokovic/sleeve), included as a **git submodule** in `themes/sleeve`.
A submodule rather than a Hugo Module because it needs no Go toolchain on Netlify and still pins an exact theme commit.

To change the theme, commit and push inside `themes/sleeve`, then commit the updated submodule pointer here:

```sh
git -C themes/sleeve commit -am "…" && git -C themes/sleeve push
git add themes/sleeve && git commit -m "Update sleeve theme"
```

To pull the latest theme: `git submodule update --remote themes/sleeve`.

## Checks

CI (`.github/workflows/build.yml`) builds the site with `--panicOnWarning`, so a broken internal link fails the build.
Run the same locally with `hugo --gc --minify --panicOnWarning`.

The CSP is currently `Content-Security-Policy-Report-Only`: after a deploy, check the browser console for violations, then rename the header to `Content-Security-Policy`.

# Misli

Source of [misli.mmatokovic.dev](https://misli.mmatokovic.dev), a Hugo site styled with Tailwind CSS v4 and deployed on Netlify.
`README.adoc` is the GitHub profile README, so project notes live here.

## Run locally

```sh
git submodule update --init   # fetch the sleeve theme
pnpm install                  # Tailwind CSS, Alpine.js, Turbo
hugo server                   # http://localhost:1313
```

Versions are pinned in one place each: Hugo in `netlify.toml` (`HUGO_VERSION`), Node in `.node-version`, pnpm in `package.json` (`packageManager`).

Croatian is the default language and lives at the site root (`content/hr`, posts under `/objave/`); English is under `/en/` (`content/en`, posts under `/en/posts/`).
Every post exists in both languages as a page bundle with the same folder name.
Start one with `hugo new content content/hr/posts/<slug>/index.md` (and the same under `content/en`); `archetypes/posts.md` fills in the front matter.

## What only works on the deployed site

- **Contact form** — handled by Netlify Forms (`data-netlify`), so submitting from `hugo server` does nothing.
- **Google Analytics and the cookie banner** — rendered only in production builds (`hugo.IsProduction`), and gtag.js loads only after the visitor accepts.
- **Headers and redirects** — security headers, the CSP and caching live in `static/_headers`; redirects in `static/_redirects`. `netlify.toml` only holds the build settings.

Deploy previews and branch deploys build with `HUGO_ENVIRONMENT=preview`, which adds `<meta name="robots" content="noindex">`.
`static/_headers` also sends `X-Robots-Tag: noindex` on every deploy, production included. That is deliberate for now; leave it unless asked.

## Theme

The layouts, CSS, JS and i18n strings come from [sleeve](https://github.com/mmatokovic/sleeve), included as a **git submodule** in `themes/sleeve`.
A submodule rather than a Hugo Module because it needs no Go toolchain on Netlify and still pins an exact theme commit.
The site repo has no `layouts/`: template changes go into the theme, site-specific settings into `hugo.toml`.

To change the theme, commit and push inside `themes/sleeve`, then commit the updated submodule pointer here.
Use `git add -A`, not `commit -a`, so new files in the theme are included; otherwise CI builds a theme commit that is missing them.

```sh
git -C themes/sleeve add -A && git -C themes/sleeve commit -m "…" && git -C themes/sleeve push
git add themes/sleeve && git commit -m "Update sleeve theme"
```

To pull the latest theme: `git submodule update --remote --merge themes/sleeve`.
`--merge` keeps `themes/sleeve` on its `main` branch; without it the submodule ends up on a detached HEAD, and theme commits made there are on no branch.

### JavaScript

`assets/js/main.js` imports one module per feature from `assets/js/modules/` (`toc.js`, `search.js`, `theme-toggle.js`, `lightbox.js`); each exports `init()`.
`js.Build` bundles them into a single deferred script loaded on every page, and each module does nothing on pages without its elements.
Keep it that way rather than loading scripts per page.

Turbo Drive replaces the body on navigation, so:

- `DOMContentLoaded` fires only on the first visit; per-page setup listens to `turbo:load` as well.
- Attach listeners to `document` and match with `closest()` / `matches()`, so they survive page swaps.
- Turbo looks up same-page anchors by the percent-encoded hash, so heading ids must be ASCII. `hugo.toml` sets `autoHeadingIDType = 'github-ascii'` for that.

### Post search

`layouts/_partials/posts-search.html` renders a lightweight list of every post in the section (cached per section and language), so the search covers all pager pages, not just the cards on screen.
`modules/search.js` folds case and diacritics (including `đ` → `d`) before matching, and hides `[data-search-paged]` while a query is active.

## Conventions

- No comments in code.
- Commit messages: a short imperative sentence ("Add …", "Fix …"), no type prefixes, no AI attribution lines.
- Tailwind classes toggled only from JS are not in `hugo_stats.json`; add them with `@source inline(...)` in `assets/css/main.css`, or toggle the `hidden` attribute instead.

## Checks

CI (`.github/workflows/build.yml`) builds the site with `--panicOnWarning`, so a broken internal link fails the build.
Run the same locally with `hugo --gc --minify --panicOnWarning`. Netlify builds with the same flag, so a broken build never deploys.

`.github/workflows/links.yml` checks external links in `content/` every Monday; a broken one fails the run and GitHub emails the failure (issues are disabled on this repo). Internal links are left to Hugo.
Dependabot (`.github/dependabot.yml`) opens monthly PRs for GitHub Actions, npm packages and the theme submodule; Hugo is updated by hand in `netlify.toml`.

Headless Chrome and Edge cannot open a remote-debugging port on this machine; to check page behaviour, load the `hugo server` pages in jsdom.

The CSP is currently `Content-Security-Policy-Report-Only`: after a deploy, check the browser console for violations, then rename the header to `Content-Security-Policy`.

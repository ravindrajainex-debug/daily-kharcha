# Daily Kharcha — Additional Product Requirements

These requirements are confirmed by the product owner and apply to the website as a whole.

## Advertising
- The entire Daily Kharcha website must be ad-free.
- Do not add third-party advertisements, sponsored placements, ad banners, pop-ups, or ad-network scripts anywhere in the product.

## Reports and usability
- Company Admin and HR users must be able to generate monthly and yearly reports easily.
- Report filters should be clear and simple: select month/year or date range, employee, department/team (where configured), expense category, and status where relevant.
- Reports should show a clear title, company name, selected period, generated date, useful totals, entry counts, and readable line-by-line details.
- Use plain labels, clear totals, sensible grouping, and short explanations so non-technical Admin/HR users can understand the report.
- Provide print-friendly A4 output and practical export options such as PDF and Excel/CSV where supported.
- Reports must respect company/tenant permissions: users may only see data they are authorized to access.

## Functional completeness
- Every visible menu item, button, tab, link, form field, filter, report action, and setting must perform its stated function.
- Do not leave decorative or dead controls in production. If a feature is not ready, label it clearly as unavailable or demo-only and do not imply that it works.
- Validate forms, show helpful success/error messages, and handle empty states.
- Test key workflows on mobile and desktop before release.

## Release quality and security
- Treat the current QR payment page as a demo until trusted server-side payment verification and subscription activation are implemented.
- Do not claim a feature is production-ready until its backend, permissions, data persistence, and user-facing workflow have been tested.

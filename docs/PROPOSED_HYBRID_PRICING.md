# Daily Kharcha — proposed hybrid subscription pricing

**Status: proposed launch pricing for owner review. Not yet published to customers or connected to billing.** The owner has selected a combination of a company fee and an employee-based fee.

## Recommended simple formula
- Company platform fee: ₹199 per company per month.
- Active employee fee: ₹30 per active employee per month.
- Minimum monthly invoice: ₹299 per company.
- Monthly charge = the greater of ₹299 or (₹199 + ₹30 × billable active employees).
- Annual option: charge 10 months of the monthly price for 12 months of service (two months' equivalent discount).
- GST, if applicable, is additional and shown separately on the invoice.

## Illustrative monthly prices

| Active employees | Monthly calculation | Monthly price | Annual price (10 months) |
|---:|---:|---:|---:|
| 1–3 | Minimum invoice | ₹299 | ₹2,990 |
| 5 | ₹199 + 5 × ₹30 | ₹349 | ₹3,490 |
| 10 | ₹199 + 10 × ₹30 | ₹499 | ₹4,990 |
| 25 | ₹199 + 25 × ₹30 | ₹949 | ₹9,490 |
| 50 | ₹199 + 50 × ₹30 | ₹1,699 | ₹16,990 |
| 100 | ₹199 + 100 × ₹30 | ₹3,199 | ₹31,990 |

## Billing definitions to implement
1. Count active employee accounts assigned to the company during the billing period; exclude pending invitations and deactivated accounts.
2. Company Admin and HR accounts should count as billable users only if they are also active employee accounts. Owner/platform accounts are never billed as customer employees.
3. Show the active-user count, company fee, per-employee fee, discount, tax and total before payment.
4. Plan changes should be transparent and take effect at the next renewal unless the customer explicitly accepts a prorated change.
5. Provide a 15-day trial for approved companies. Trial duration and eligibility are configurable by the Platform Owner; no automatic paid conversion without clear notice and consent.
6. Allow monthly and annual subscriptions. Record manual UPI/bank payments initially; mark a subscription paid only after the Platform Owner verifies the payment.
7. Give each company an invoice/receipt and show renewal date, payment status and subscription status.
8. Never delete customer records automatically just because a subscription expires. Provide a clear read/export and retention/grace-period policy before launch.

## Owner controls
- Platform Owner can edit the company fee, per-active-employee fee, minimum invoice, trial duration, annual discount, tax display and effective date.
- Price changes apply prospectively and must be communicated before renewal.
- Keep an immutable record of the price calculation and payment confirmation for each invoice.

## Commercial caution
These amounts are a starting proposal for a low-cost India-focused launch, not a market guarantee. Validate willingness to pay with a small pilot group and review hosting, support, tax and payment costs before public launch. Do not advertise or collect subscription payments until billing terms, GST treatment, privacy policy, terms of service and refund/cancellation rules are ready.
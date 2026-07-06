"""E.164 phone normalization at the API boundary.

Kenya-first: accepts the shapes agents/caretakers actually type
(0712…, 712…, 254712…, +254712…) and returns a canonical +2547XXXXXXXX.
Ported in spirit from the OTP module's normalizer.
"""

import re

KE_COUNTRY_CODE = "254"


class InvalidPhoneNumber(ValueError):
    pass


def normalize_phone(raw: str, default_country: str = KE_COUNTRY_CODE) -> str:
    """Return an E.164 number (leading +). Raises InvalidPhoneNumber on garbage."""
    if raw is None:
        raise InvalidPhoneNumber("empty phone")

    # Strip everything except digits and a leading +.
    cleaned = raw.strip()
    has_plus = cleaned.startswith("+")
    digits = re.sub(r"\D", "", cleaned)

    if not digits:
        raise InvalidPhoneNumber(f"no digits in {raw!r}")

    if has_plus:
        e164 = digits
    elif digits.startswith("0"):
        # Local trunk form: 0712… → 254712…
        e164 = default_country + digits[1:]
    elif digits.startswith(default_country):
        e164 = digits
    elif len(digits) == 9:
        # Bare subscriber number: 712345678 → 254712345678
        e164 = default_country + digits
    else:
        e164 = digits

    # Kenyan mobile numbers are 254 + 9 digits.
    if e164.startswith(KE_COUNTRY_CODE) and len(e164) != 12:
        raise InvalidPhoneNumber(f"not a valid KE number: {raw!r}")

    return "+" + e164


def normalize_phone_or_blank(raw: str) -> str:
    """Lenient variant for optional fields — blank in, blank out."""
    if not raw:
        return ""
    return normalize_phone(raw)

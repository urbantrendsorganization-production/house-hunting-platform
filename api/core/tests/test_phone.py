import pytest

from core.services.phone import InvalidPhoneNumber, normalize_phone, normalize_phone_or_blank


@pytest.mark.parametrize(
    "raw,expected",
    [
        ("0712345678", "+254712345678"),
        ("712345678", "+254712345678"),
        ("254712345678", "+254712345678"),
        ("+254712345678", "+254712345678"),
        ("+254 712 345 678", "+254712345678"),
        ("0712-345-678", "+254712345678"),
    ],
)
def test_normalize_valid_forms(raw, expected):
    assert normalize_phone(raw) == expected


@pytest.mark.parametrize("raw", ["", "abc", "0712", "254123"])
def test_normalize_rejects_garbage(raw):
    with pytest.raises(InvalidPhoneNumber):
        normalize_phone(raw)


def test_blank_variant_passes_blank_through():
    assert normalize_phone_or_blank("") == ""
    assert normalize_phone_or_blank("0712345678") == "+254712345678"


@pytest.mark.parametrize("raw", ["+254", "254", " +254 ", "+", "  "])
def test_blank_variant_treats_country_code_only_as_blank(raw):
    # The capture form pre-fills "+254"; an untouched optional field must not
    # fail the whole building sync.
    assert normalize_phone_or_blank(raw) == ""


def test_blank_variant_still_raises_on_malformed_subscriber_digits():
    # A partially typed real number is a genuine data-entry error, not blank.
    with pytest.raises(InvalidPhoneNumber):
        normalize_phone_or_blank("+25471")

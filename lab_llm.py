"""Small helpers for mapping one lab model setting into runtime-specific variants."""

from __future__ import annotations


def source_model_name(raw_model: str | None = None, default: str = "gpt-4o") -> str:
    model_name = (raw_model or "").strip()
    return model_name or default


def is_openai_native_model(model_id: str | None) -> bool:
    model_name = str(model_id or "").strip().lower()
    if not model_name:
        return False

    if model_name.startswith(("gpt-", "chatgpt-", "codex-")):
        return True

    return model_name.startswith(("o1", "o3", "o4", "o5"))


def litellm_model_name(raw_model: str | None = None, default: str = "gpt-4o") -> str:
    model_name = source_model_name(raw_model, default=default)

    if "/" in model_name:
        return model_name

    if is_openai_native_model(model_name):
        return model_name

    return f"openai/{model_name}"

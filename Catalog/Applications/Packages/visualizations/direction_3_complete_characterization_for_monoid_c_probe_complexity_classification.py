def probe_complexity_single_obj(n: int) -> int:
    """Probe complexity of SingleObj(M) for a monoid of order n."""
    return 0 if n == 1 else 1
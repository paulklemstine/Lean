def compression_safe(op_norm: float, delta: float, decoder_radius: float) -> bool:
    """Certify Theorem 8: amplified noise stays within the decoder's window.

    Returns True iff ||f|| * delta <= decoder_radius, in which case any noise e
    with ||e|| <= delta decodes correctly after linear compression by f.
    """
    if op_norm < 0 or delta < 0:
        raise ValueError("op_norm and delta must be nonnegative")
    return op_norm * delta <= decoder_radius

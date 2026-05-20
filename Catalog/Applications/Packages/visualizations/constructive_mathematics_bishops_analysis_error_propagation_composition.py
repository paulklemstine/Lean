def chain_precision(moduli, target_bits):
    """Compute required input precision for a chain of modulus-continuous functions."""
    p = target_bits
    for mu in reversed(moduli):
        p = mu(p)
    return p

# Example: sensor -> amplifier -> ADC
moduli = [
    lambda n: n + 7,  # sensor (7 bits noise)
    lambda n: n + 7,  # amplifier (gain=100, ~7 bits)
    lambda n: n + 1,  # ADC quantization
]

for target in [4, 8, 12, 16, 20]:
    required = chain_precision(moduli, target)
    print(f"Target: {target} bits -> Need: {required} bits input precision")
    print(f"  Input tolerance: {1/2**required:.2e}, Output tolerance: {1/2**target:.2e}")

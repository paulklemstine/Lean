def pro_spectrum(base_euler, length):
    return [base_euler if n % 2 == 0 else 2 - base_euler for n in range(length)]
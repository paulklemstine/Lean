def find_qeml_preimage(target: complex) -> tuple:
    if np.isclose(target, -1.0):
        return (1j * np.pi, complex(1.0))
    else:
        return (np.log(target + 1), complex(np.e))
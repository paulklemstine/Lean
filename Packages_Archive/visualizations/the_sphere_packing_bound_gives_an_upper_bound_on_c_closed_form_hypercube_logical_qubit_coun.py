def hypercube_betti1(n: int) -> int:
    """First Betti number of the n-dimensional hypercube graph Q_n.

    Q_n has 2^n vertices and n*2^(n-1) edges and is connected, so by Euler's
    relation beta_1 = |E| - |V| + 1 = n*2^(n-1) - 2^n + 1.  This equals the
    number of logical qubits of the hypercube CSS code.
    """
    return n * 2 ** (n - 1) - 2 ** n + 1

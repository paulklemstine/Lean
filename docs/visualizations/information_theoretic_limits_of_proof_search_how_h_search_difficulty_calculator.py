def sparse_proof_search_bound(b, n, k):
    assert b >= 2 and k + 1 <= n
    return b ** (n - k - 1)
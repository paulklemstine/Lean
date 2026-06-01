def build_oracle_chain(base_model, depth):
    chain = [base_model]
    for _ in range(depth):
        prev = chain[-1]
        antidiag = lambda n, m=prev: 1 - m.phi(n, n)
        new_fns = prev.functions + [antidiag]
        chain.append(ComputabilityModel(new_fns))
    return chain
def build_oracle_chain(jump, base, levels):
    chain = [set(base)]
    for _ in range(levels):
        chain.append(jump(chain[-1]))
    return chain
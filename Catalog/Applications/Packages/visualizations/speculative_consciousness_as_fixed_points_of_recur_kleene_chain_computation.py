def kleene_chain(phi, bot, max_steps=100):
    chain = [bot]
    for _ in range(max_steps):
        next_val = phi(chain[-1])
        chain.append(next_val)
        if next_val == chain[-2]:
            break
    return chain
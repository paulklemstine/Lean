def reconstruct_invariants(step, states, X):
    complement = states - X
    assert all(step[s] in X for s in X), "X not invariant"
    assert all(step[s] in complement for s in complement), "Complement not invariant"
    return (lambda s: s in X), (lambda s: s in complement)

step = {0:1, 1:2, 2:0, 3:4, 4:5, 5:3}
states = set(range(6))
safety, liveness = reconstruct_invariants(step, states, {0,1,2})
print(f"Safety(0)={safety(0)}, Liveness(3)={liveness(3)}")
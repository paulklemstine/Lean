# Tropical DeltaNet Proposal

## Research Question

Can Qwen3.6's Gated DeltaNet be expressed in the tropical (min-plus) semiring?

## Standard DeltaNet Recurrence

```
s_t = Λ_t ⊙ s_{t-1} + k_t v_t^T
```

Where:
- `Λ_t` is a data-dependent decay gate (element-wise)
- `s_t` is the recurrent state
- `k_t`, `v_t` are key and value vectors

## Tropical Analogue

In the tropical semiring, `+` is `min` and `×` is `+`.

```
s_t = min( Λ_t + s_{t-1},  k_t + v_t )
```

This replaces:
- Multiplicative gating `⊙` with tropical multiplication `+`
- Additive combination with tropical addition `min`

## Properties to Verify

1. **Decay preservation**: If `Λ_t < 0`, then `Λ_t + s_{t-1}` shrinks the state (tropical decay)
2. **Associativity**: Tropical addition (`min`) is associative
3. **Distributivity**: `min(a, b+c) = min(a, b) + min(a, c)` does NOT hold in tropical semiring — this is a potential limitation
4. **Convergence**: Does the tropical recurrence converge to a fixed point?

## Next Steps

- Implement `CrystallineDeltaLayer` with tropical recurrence
- Compare MSE between standard and tropical DeltaNet on random sequences
- Measure perplexity when distilling Qwen3.6 into CrystallineMoEModel

# Computational Evidence: Logistic–Tent Conjugacy

We test the intertwining identity `f(h(t)) = h(T(t))` with
`f(x)=4x(1-x)`, `T(t)=1-|2t-1|`, `h(t)=sin²(πt/2)`.

## 1. Pointwise check of the conjugacy

For sample seeds `t` we compare `f(h(t))` and `h(T(t))`:

| t     | h(t)      | f(h(t))   | T(t)   | h(T(t))   | match |
|-------|-----------|-----------|--------|-----------|-------|
| 0.10  | 0.024472  | 0.095492  | 0.20   | 0.095492  | ✓     |
| 0.25  | 0.146447  | 0.500000  | 0.50   | 0.500000  | ✓     |
| 0.40  | 0.345492  | 0.904508  | 0.80   | 0.904508  | ✓     |
| 0.50  | 0.500000  | 1.000000  | 1.00   | 1.000000  | ✓     |
| 0.60  | 0.654508  | 0.904508  | 0.80   | 0.904508  | ✓     |
| 0.75  | 0.853553  | 0.500000  | 0.50   | 0.500000  | ✓     |
| 0.90  | 0.975528  | 0.095492  | 0.20   | 0.095492  | ✓     |

The identity holds to machine precision across the whole interval, including the
fold at `t = 1/2` where the tent branch switches.

## 2. Fixed-point correspondence

- Tent fixed points solve `T(t)=t`: `t=0` (left ramp `2t=t`) and `t=2/3`
  (right ramp `2-2t=t`).
- Their images: `h(0)=0`, `h(2/3)=sin²(π/3)=3/4`.
- These are exactly the logistic fixed points (`f(0)=0`, `f(3/4)=3/4`), confirming
  the transport of fixed points.

## 3. Period-two orbit

- Tent 2-cycle: `T(2/5)=4/5`, `T(4/5)=2/5`, so `T²(2/5)=2/5` and `2/5 ≠ 4/5`.
- Images under `h`: `h(2/5)=sin²(π/5)≈0.345492`, `h(4/5)=sin²(2π/5)≈0.904508`.
- Check: `f(0.345492)=0.904508`, `f(0.904508)=0.345492`, so `f²(0.345492)=0.345492`
  with `f(0.345492)≠0.345492` — a genuine logistic 2-cycle.

## 4. Monotonicity / bijectivity of h

Sampling `h` on a grid of `[0,1]` gives a strictly increasing sequence from
`h(0)=0` to `h(1)=1`; combined with continuity this is consistent with `h` being a
homeomorphism of the unit interval, as proved.

## Conclusion

All computational checks are consistent with the formal theorems: the conjugacy is
exact (not approximate), fixed and periodic points transfer, and `h` is a strictly
increasing bijection of `[0,1]`.

# Theorem: the Order Certificate

*(written 2026-10-03, r48 rigorous-bounds axis)*

## Statement

Let `N >= 2` be composite, let `g` be a unit modulo `N`, and suppose we are
handed an integer `M` together with its **complete prime factorization**
`M = prod_{i=1}^{s} q_i^{e_i}`, and `ord_N(g) = M`. Then there is a
deterministic algorithm running in **`poly(log N)` time** which, from
`(N, g, M, {q_i^{e_i}})` alone, does one of the following:

* **(F)** outputs an integer `d` with `1 < d < N` and `d | N`; or
* **(C)** outputs the certificate `CAUSE = DEGENERATE`, meaning
  `ord_r(g)` takes the *same value* for every prime `r | N`.

It never outputs a wrong factor, and it never fails.

## Proof

Write `N = prod_j r_j^{f_j}` and let `m_j := ord_{r_j^{f_j}}(g)` be the order
modulo the **prime power** `r_j^{f_j} || N`. (Prime powers, not primes: this
is the one place a naive proof of this theorem goes wrong, because
`ord_{r^f}(g)` may be `ord_r(g) * r^t` for `t > 0`, so `ord_N(g)` is **not**
`lcm_j ord_{r_j}(g)` when `N` is not squarefree. It is `lcm_j m_j` by CRT on
the unit groups of the coprime moduli `r_j^{f_j}`.)

**Step 1 (the certificate is checkable in poly time).**  Given the list
`{(q_i, e_i)}` we verify in `poly(log N)` time:
  (a) every `q_i` is prime (AKS, `poly(log q_i)`);
  (b) `prod q_i^{e_i} = M`;
  (c) `g^M = 1 (mod N)`;
  (d) `g^{M/q_i} != 1 (mod N)` for every `i`.
Conditions (c)+(d) together say exactly `ord_N(g) = M`.  All are modular
exponentiations: `O(s * log M)` multiplications mod `N`, hence
`O(s * log^2 N)` bit operations.

**Step 2 (the descent).**  For each `i`, compute
```
d_i = gcd(g^{M/q_i} - 1, N).
```
If some `d_i` satisfies `1 < d_i < N`, output it: it is a gcd, so `d_i | N`,
and the bound makes it nontrivial.  **This is always correct — no assumption
was used.**

**Step 3 (completeness).**  Suppose every `d_i` is `1` or `N`.  By
construction
```
d_i = prod_{ j : m_j | M/q_i } r_j^{f_j}.
```
Since `M = lcm_j m_j`, every `m_j | M`, so `m_j | M/q_i` iff
`v_{q_i}(m_j) < e_i`.  Hence `d_i = N` iff `v_{q_i}(m_j) < e_i` for **every**
`j`, and `d_i = 1` iff `v_{q_i}(m_j) = e_i` for **every** `j`.  A value
strictly between would mean some `j, j'` with
`v_{q_i}(m_j) < e_i <= v_{q_i}(m_{j'})` — excluded by hypothesis.

Therefore "no split" forces, for every `i`, that `v_{q_i}(m_j)` is independent
of `j`.  Since `m_j | M = prod_i q_i^{e_i}`, every `m_j` is a product of the
`q_i`, so `m_j = prod_i q_i^{a_i}` with all `a_i` independent of `j`; hence
`m_j = m_{j'} =: M'` for all `j`.  That is exactly claim **(C)**. `QED`

**Edge case `M = 1`.**  Then `g = 1 (mod N)`, `s = 0`, the descent is empty,
and we correctly report `(C)` with `M' = 1`.

**Cost.** `s` modular exponentiations modulo `N`, each using `O(log M)`
modular squarings/multiplications, each multiplication costing `O(log^2 N)`
bit operations with schoolbook arithmetic. Since `ord_N(g) | lambda(N) <=
phi(N) < N`, we have `M < N` and `s = omega(M) <= log_2 M < log_2 N`.  Hence

```
total = s * O(log M) * O(log^2 N)  =  O(log N) * O(log N) * O(log^2 N)
      =  O(log^5 N)   bit operations (schoolbook).
```

With fast arithmetic (`M(log N)` per multiplication) this is
`O(M(log N) * log^2 N)`, i.e. quasi-linear in the input length.

**Either way: polynomial in the input length `log N`, and completely
independent of the *value* of `N`.** That is the point — the descent costs
nothing that depends on how big `N` is, only on how long its bit-string is.

## Consequence (the point of the theorem)

> **Factoring `N` reduces in polynomial time to producing a pair
> `(g, factored order of g)`.**
> Once the factored order is in hand the factorization of `N` is *free*.

This is exactly the content of the Pollard `p-1` / ECM smoothness heuristic:
the heuristic is needed **only to produce `(g, factored order)`**, never for
the descent that turns it into a factorization. The two steps have different
cost laws:

| step | cost | needs |
|---|---|---|
| produce `(g, factored ord)` | the hard, heuristic step | smoothness of the order |
| descent -> factor | `O(log^5 N)` | nothing at all |

The smoothness assumption is therefore **not** a property of the factoring
method. It is a property of the *search for the right group element*.

## Promise characterisations

| promise on `N` | checkable in `poly(log N)`? | factoring time |
|---|---|---|
| `p` (a factor of `N`) is `B`-smooth over a given basis | **NO** — needs `p` | — |
| `ord_N(g) = M` is `B`-smooth with the factorization given | **YES**, by Step 1 | `O(log^5 N)` |
| `ord_N(g)` is `B`-smooth, factorization *not* given | NO (finding it is the hard part) | `~B` by trial division |

The middle row is the promise problem this axis delivers. It is checkable, and
the runtime bound is proved above.
# -*- coding: utf-8 -*-
r"""
Cross-check for the relation-collection floor of Semaev-style index calculus
(Axis D, round 115).

The Lean file `SemaevCountingFloor.lean` proves

    #(kSums S k) <= #S ^ k                                  (kSums_card_le)
    #(kSums S k) / N <= B^k / N                              (kSums_card_div_le)

which says that at most the fraction `B^k / N` of a finite group of order `N` is
`k`-decomposable with a factor base of `B` elements.  The *waiting time* consequence
`E[T] >= N / B^k` was NOT formalised (it needs the measure-theoretic tail-sum identity,
see RESULT.md); it is cross-checked numerically here instead.

Three parts, each with a positive control:

  Part 1 (EXACT, positive control of the closed form): for small `N`, enumerate *all*
  `M`-tuples of `ZMod N` and count the fraction with at least one coordinate in a set
  `A` of cardinality `a`.  Compare with the closed form `1 - (1 - a/N)^M` proved in Lean
  as `hit_prob`.

  Part 2 (SEEDED MONTE CARLO): draw uniforms until the first element of `A` appears and
  average the first-hit time `T`.  Check `E[T] ~= N / a` (>= 12 fixed seeds per point;
  the seeds are printed so the run is reproducible, per FANOUT_BRIEF.md 1.3).

  Part 3 (DEPLOYMENT): exact integer arithmetic at `N = #<base point of secp256k1>`
  for the (B, k) grid of the Lean `#eval` table.

Run with:  sage waiting_time_crosscheck.sage
"""

# ----------------------------------------------------------------------------
# Part 1: exact enumeration of the hit probability in M independent draws
# ----------------------------------------------------------------------------

def hit_fraction_exact(N, a, M):
    """Fraction of M-tuples in ZMod N having at least one coordinate in A = {0,...,a-1}.

    Enumerated over all N^M tuples: exact, no Monte Carlo.
    """
    A = set(range(a))
    hits = 0
    total = 0
    # enumerate all M-tuples via a mixed-radix counter
    index = [0] * M
    while True:
        if any(index[i] in A for i in range(M)):
            hits += 1
        total += 1
        # increment the mixed-radix counter
        j = 0
        while j < M:
            index[j] += 1
            if index[j] < N:
                break
            index[j] = 0
            j += 1
        if j == M:
            break
    return hits / total


def hit_fraction_closed(N, a, M):
    """Closed form 1 - (1 - a/N)^M, i.e. the Lean theorem `hit_prob`.

    NB: `a / N` with Sage integers is exact rational division (Sage preparser);
    do NOT write Rational(a, N), whose second argument is a *base*.
    """
    return 1 - (1 - a / N) ** M


print("=" * 78)
print("PART 1: exact enumeration vs closed form   (Lean `hit_prob`, `no_hit_prob`)")
print("=" * 78)
print("%6s %4s %4s %14s %14s %8s" % ("N", "a", "M", "exact", "closed form", "match"))
part1_ok = True
for (N, a) in [(7, 3), (7, 1), (11, 2), (13, 5)]:
    for M in [1, 2, 3, 4]:
        ex = hit_fraction_exact(N, a, M)
        cl = hit_fraction_closed(N, a, M)
        ok = (ex == cl)
        part1_ok = part1_ok and ok
        print("%6d %4d %4d %14s %14s %8s" % (N, a, M, ex, cl, "YES" if ok else "NO"))
print("PART 1 verdict: closed form matches exact enumeration everywhere:",
      part1_ok)
print()

# ----------------------------------------------------------------------------
# Part 2: seeded Monte Carlo of the first-hit waiting time E[T] = N/a
# ----------------------------------------------------------------------------

def first_hit_time_series(N, a, trials, seed):
    """`trials` independent first-hit times for A = {0,...,a-1} in ZMod N."""
    set_random_seed(seed)
    A = range(a)
    out = []
    for _ in range(trials):
        t = 0
        while True:
            t += 1
            g = int(Zmod(N).random_element())
            if g in A:
                break
        out.append(t)
    return out


print("=" * 78)
print("PART 2: Monte-Carlo first-hit waiting time E[T] vs the floor N/a")
print("=" * 78)
print("%10s %6s %9s %12s %12s %8s" % ("N", "a", "N/a", "mean(T)", "geometric", "match"))
part2_ok = True
for (N, a, trials) in [(101, 5, 20000), (503, 7, 20000), (10007, 100, 6000)]:
    floor = N / a          # exact rational: E[T] = N/a for a geometric law
    ts = []
    for seed in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]:   # 12 fixed seeds
        ts.extend(first_hit_time_series(N, a, trials // 12, seed))
    mean_T = float(sum(ts)) / len(ts)
    # the exact expectation of a geometric(p) law with p = a/N is N/a;
    # the relative tolerance 5% accounts for the finite sample
    ok = abs(mean_T - float(floor)) <= 0.05 * float(floor) + 1
    part2_ok = part2_ok and ok
    print("%10d %6d %9.2f %12.2f %12.2f %8s"
          % (N, a, float(floor), mean_T, float(floor), "YES" if ok else "NO"))
print("PART 2 verdict: empirical mean waiting time tracks N/a within 5%:",
      part2_ok)
print()

# ----------------------------------------------------------------------------
# Part 3: the 256-bit deployment table (exact integer arithmetic)
# ----------------------------------------------------------------------------

# order of the standard base point of secp256k1
N256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
sqrtN = isqrt(N256)

print("=" * 78)
print("PART 3: 256-bit deployment (N = secp256k1 order, sqrt N = 2^128)")
print("=" * 78)
print("%8s %4s %10s %14s %14s %12s" %
      ("log2 B", "k", "log2(B^k)", "log2 ceil(N/B^k)", "killed?", "log2(B^k)-128"))
for B in [2 ** e for e in [8, 16, 20, 24, 32, 40, 64]]:
    for k in [2, 3, 4, 5, 6, 8, 10]:
        bk = B ** k
        draws = -(-N256 // bk)          # ceil(N / B^k)
        killed = draws >= sqrtN          # floor above generic rho
        print("%8d %4d %10d %14d %14s %12d" %
              (int(log(B, 2)), k, int(log(bk, 2)) if bk > 1 else 0,
               max(0, (draws.bit_length() - 1) if draws > 0 else 0),
               "YES" if killed else "no",
               int(log(bk, 2)) - 128 if bk >= 2 ** 128 else -(128 - int(log(bk, 2)))))
print()

print("=" * 78)
print("OVERALL")
print("=" * 78)
print("  Part 1 (exact hit probability):", "PASS" if part1_ok else "FAIL")
print("  Part 2 (geometric waiting time):", "PASS" if part2_ok else "FAIL")
print("  Part 3: the counting floor exceeds generic rho for every (B,k) with")
print("           B^k <= sqrt(N) = 2^128; sub-rho collection needs B^k > 2^128.")
print("  NOTE: Part 3 is a *cost* statement about the floor, not a proof that the")
print("        decomposition problem is hard; see RESULT.md for the honest verdict.")

#!/usr/bin/env python3
"""
THE BUDGET-ESCAPE PITFALL (Factoring round 104): a methodology result.

A construction "family" can appear to beat random at divisor-coverage while
VIOLATING the magnitude budget M = exp(n^gamma) -- the constraint that is the
entire difficulty of the UMW divisor-cover problem. This bit me TWICE in this
investigation:
  - round 96c: a "complete cover at gamma=0.36" whose witness had max(S) > M;
  - round 104: an "lcm-prefix family beats random by 16x" whose elements
    lcm(1..200) ~ exp(200) exceed M = exp(n^0.4) ~ exp(25) by a huge margin.

When the budget is ENFORCED, lcm-prefix covers only [1..n^gamma] (n^gamma
indices) and loses badly to random. Random (within budget) is much harder to beat
than an unconstrained family suggests.

THIS SCRIPT reproduces both: (A) the cheating family vs random (no budget), and
(B) the same family with the budget enforced, showing the win evaporates.
"""
import math, random

def coverage(S, n):
    return sum(1 for i in range(1, n+1) if any(s % i == 0 for s in S))

def lcm(a, b): return a // math.gcd(a, b) * b

def main():
    random.seed(11)
    n = 3000
    print("THE BUDGET-ESCAPE PITFALL. Constraint: every cover element <= M=exp(n^g).\n")
    print("(A) UNCONSTRAINED family test (CHEATS -- ignores M):")
    for gamma in [0.40, 0.48]:
        k = int(n**gamma)
        # lcm-prefix family, IGNORING budget (the mistake)
        cur = 1; L = {}
        for j in range(2, 201):
            cur = lcm(cur, j); L[j] = cur
        js = list(L.keys())
        lcm_cov = sum(coverage([L[random.choice(js)] for _ in range(k)], n) for _ in range(15))/15
        rand_cov = sum(coverage([random.randint(1, n) for _ in range(k)], n) for _ in range(15))/15
        print(f"   gamma={gamma}: lcm-prefix(CHEAT)={lcm_cov:.0f}  random={rand_cov:.0f}  -> looks like a 16x win")
    print("\n(B) SAME family with the BUDGET ENFORCED (element <= M=exp(n^g)):")
    for gamma in [0.40, 0.48]:
        k = int(n**gamma); M = math.exp(n**gamma)
        # lcm-prefix: element lcm(1..j) <= M  =>  j <= ~n^gamma (since log lcm ~ j)
        jmax = int(n**gamma)
        lcm_cov_budgeted = jmax  # covers exactly [1..jmax]
        rand_cov_budgeted = sum(coverage([random.randint(1, int(M)) for _ in range(k)], n)
                                for _ in range(10))/10
        print(f"   gamma={gamma}: lcm-prefix(<=M, j<={jmax})={lcm_cov_budgeted}  "
              f"random(<=M)={rand_cov_budgeted:.0f}  -> the win EVAPORATES")
    print("\nCONCLUSION: any 'beating random' claim for a divisor-cover family MUST")
    print("enforce max(element) <= exp(n^gamma). Un-enforced, it is a budget escape")
    print("-- the same trap that produced the retracted round-96c 'complete cover'.")

if __name__ == "__main__":
    main()

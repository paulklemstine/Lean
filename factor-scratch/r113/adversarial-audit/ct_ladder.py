"""
HARNESS INTEGRITY CONTROL for ecm.py's Montgomery arithmetic.

If xDBL/xADD/the ladder are wrong, the ECM finds nothing and a NULL would be
read as a measurement (the exact defect class that killed r110-r112 harnesses).
So: verify the projective arithmetic against INDEPENDENT affine arithmetic on a
small prime, exhaustively, over many k and many curves/points.

Run: python3 ct_ladder.py
"""
import random
import ecm

def affine_mul(P, k, A, n):
    x, y = P
    def add(P1, P2):
        x1, y1 = P1; x2, y2 = P2
        if x1 == x2:
            if (y1 + y2) % n == 0:
                return None
            m = (3 * x1 * x1 + 2 * A * x1 + 1) * pow(2 * y1, -1, n) % n
        else:
            m = (y2 - y1) * pow(x2 - x1, -1, n) % n
        x3 = (m * m - A - x1 - x2) % n
        return (x3, (m * (x1 - x3) - y1) % n)
    R = None
    if k == 0:
        return (x, 0)
    R = P
    for _ in range(k - 1):
        R = add(R, P)
        if R is None:
            return None
    return R


def main():
    n, A = 101, 1
    a24 = (A + 2) * pow(4, -1, n) % n
    # all points of the curve
    pts = []
    for xx in range(1, n):
        v = (xx * xx * xx + A * xx * xx + xx) % n
        for yy in range(0, n):
            if yy * yy % n == v:
                pts.append((xx, yy))
    total = 0
    bad = 0
    for (px, py) in pts:
        P = (px, py)
        # affine order, capped
        order = None
        for k in range(1, 200):
            if affine_mul(P, k, A, n) is None:
                order = k
                break
        if order is None or order < 60:
            continue
        for k in range(1, min(order - 1, 80)):
            lx, lz = ecm._mul_k(px, 1, k, a24, n)
            got = lx * pow(lz, -1, n) % n if lz else None
            want = affine_mul(P, k, A, n)[0]
            total += 1
            if got != want:
                bad += 1
                if bad <= 5:
                    print("  MISMATCH P=%s k=%d got=%s want=%s" % (P, k, got, want))
    print("ladder checked %d (point,k) pairs against affine; mismatches = %d" % (total, bad))

    # xADD spot check against affine addition, using ladder-computed operands
    bad2 = 0
    tot2 = 0
    for (px, py) in pts[:12]:
        a24 = (A + 2) * pow(4, -1, n) % n
        for a in range(1, 12):
            for b in range(1, 12):
                if a == b:
                    continue
                if affine_mul((px, py), a + b, A, n) is None:
                    continue
                x1, z1 = ecm._mul_k(px, 1, a, a24, n)
                x2, z2 = ecm._mul_k(px, 1, b, a24, n)
                x3, z3 = ecm._mont_xadd(x1, z1, x2, z2, n)
                got = x3 * pow(z3, -1, n) % n if z3 else None
                want = affine_mul((px, py), a + b, A, n)[0]
                tot2 += 1
                if got != want:
                    bad2 += 1
                    if bad2 <= 5:
                        print("  XADD MISMATCH P=%s a=%d b=%d got=%s want=%s" % ((px, py), a, b, got, want))
    print("xADD checked %d pairs against affine; mismatches = %d" % (tot2, bad2))
    if bad or bad2:
        print("\nHARNESS BROKEN -- ECM results from this file would be VOID")
        raise SystemExit(1)
    print("\nHARNESS VERIFIED -- Montgomery arithmetic is exact.")


if __name__ == "__main__":
    main()

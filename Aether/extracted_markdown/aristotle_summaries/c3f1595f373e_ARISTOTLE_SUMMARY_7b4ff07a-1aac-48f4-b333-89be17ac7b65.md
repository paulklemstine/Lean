# Summary of changes
Created `factor_rsa.py` — a comprehensive Python script for factoring large integers, targeting the RSA challenge numbers.

## Algorithms Implemented
1. **Trial Division** — tests small primes up to 1M
2. **Pollard's Rho** — with Brent's cycle detection improvement, effective for factors up to ~30 digits
3. **Pollard's p-1** — two-stage, finds factors where p-1 is smooth
4. **Fermat's Factorization** — finds factors close to √n
5. **Elliptic Curve Method (ECM)** — Montgomery curve implementation with multiple B1 bounds
6. **Quadratic Sieve** — simplified implementation for numbers up to ~80 digits

## Features
- **CLI interface** with multiple modes: `--benchmark`, `--verify`, `--target RSA-100`, `--number 12345`
- **Known factorization verification** for RSA-100, RSA-120, RSA-129, RSA-130, RSA-140, RSA-155
- **Automatic algorithm orchestration** — tries methods in order of speed/applicability
- **Miller-Rabin primality testing** (deterministic for numbers < 3.3×10²⁴)
- **Configurable time limits** per target

## Testing Results
- ✅ Correctly factors multi-factor composites (e.g., 98765432198765432197 = 53 × 509 × 19139 × 46027 × 4156037)
- ✅ Fermat's method finds close factors (15-digit factors found instantly)
- ✅ Pollard's p-1 finds 20-digit factors
- ✅ All verified known factorizations pass

## Limitations
RSA numbers with factors > ~40 digits require specialized C libraries (CADO-NFS, msieve, yafu) with massive distributed computation. The unfactored RSA targets (RSA-260 through RSA-2048) are beyond the reach of any pure Python implementation — RSA-2048 alone would require an estimated ~2¹⁰⁰ operations with the best known algorithms (GNFS).
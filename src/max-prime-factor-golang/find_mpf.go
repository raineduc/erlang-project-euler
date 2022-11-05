package main

func FindMPF(n int) int {
	if n < 1 {
		panic("n must be greater than 0")
	}
	maxFactor := -1
	d := 2
	for ; n > 1; {
		for ; n % d == 0; n /= d {
			if d > maxFactor {
				maxFactor = d
			}
		}
		d += 1
		if d*d > n {
			if n > 1 && n > maxFactor {
				maxFactor = n
			}
			break
		}

	}
	return maxFactor
}

package main

func sumDiagonals(n int) int {
	if n % 2 == 0 {
		panic("n must be odd")
	}

	if n < 1 {
		panic("n must be greater than 0")
	}

	spiralsNumber := n / 2 + 1

	sum := 1
	last := 1
	for i := 1; i < spiralsNumber; i++ {
		for j := 1; j < 5; j++ {
			last += 2*i
			sum += last
		}
	}
	return sum
}

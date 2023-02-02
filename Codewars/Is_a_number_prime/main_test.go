package kata

import "testing"

func TestIsPrime(t *testing.T) {
	type args struct {
		n int
	}
	tests := []struct {
		name string
		args args
		want bool
	}{
		{"-1 is not a prime nuber", args{-1}, false},
		{"0 is not a prime number", args{0}, false},
		{"1 is not a prime number", args{1}, false},
		{"4 is not a prime number", args{4}, false},
		{"6 is not a prime number", args{6}, false},
		{"8 is not a prime number", args{8}, false},
		{"9 is not a prime number", args{9}, false},
		{"1105 is not a prime number", args{1105}, false},
		{"512463 is not a prime number", args{512463}, false},
		// {"8635844967113809 is not a prime number", args{8635844967113809}, false},
		{"2 is a prime number", args{2}, true},
		{"3 is a prime number", args{3}, true},
		{"5 is a prime number", args{5}, true},
		{"7 is a prime number", args{7}, true},
		{"557 is a prime number", args{557}, true},
		{"99991 is a prime number", args{99991}, true},
		// {"9007199254740997 is a prime number", args{9007199254740997}, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := IsPrime(tt.args.n); got != tt.want {
				t.Errorf("IsPrime() = %v, want %v", got, tt.want)
			}
		})
	}
}

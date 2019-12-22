package lib

import (
	"reflect"
	"testing"
)

func TestGenerateCase1(t *testing.T) {
	actual := Generate(0)
	expected := [][]int{}
	if !reflect.DeepEqual(actual, expected) {
		t.Fatalf("expected: %v, actual: %v", expected, actual)
	}
}

func TestGenerateCase2(t *testing.T) {
	actual := Generate(1)
	expected := [][]int{[]int{1}}
	if !reflect.DeepEqual(actual, expected) {
		t.Fatalf("expected: %v, actual: %v", expected, actual)
	}
}

func TestGenerateCase3(t *testing.T) {
	actual := Generate(5)
	expected := [][]int{
		[]int{1},
		[]int{1, 1},
		[]int{1, 2, 1},
		[]int{1, 3, 3, 1},
		[]int{1, 4, 6, 4, 1},
	}
	if !reflect.DeepEqual(actual, expected) {
		t.Fatalf("expected: %v, actual: %v", expected, actual)
	}
}

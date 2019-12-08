package lib

import (
	"reflect"
	"testing"
)

func TestGenerate(t *testing.T) {
	if len(Generate(1)) != 1 {
		t.Errorf("error")
	}

	actual := Generate(1)
	expected := [][]int{[]int{1}}
	if !reflect.DeepEqual(actual, expected) {
		t.Fatalf("expected: %v, actual: %v", expected, actual)
	}
}

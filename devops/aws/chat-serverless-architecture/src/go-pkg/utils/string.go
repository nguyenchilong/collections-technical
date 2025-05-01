package utils

import (
	"regexp"
	"strings"
)

// Check string is empty
func Empty(s string) bool {
	return strings.Trim(s, " ") == ""
}

// VerifyEmailFormat email verify
func VerifyEmailFormat(email string) bool {
	pattern := `^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$`

	reg := regexp.MustCompile(pattern)
	return reg.MatchString(email)
}

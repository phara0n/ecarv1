#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=========================================${NC}"
echo -e "${YELLOW}   eCar Garage Application Test Suite    ${NC}"
echo -e "${YELLOW}=========================================${NC}"

# Store current directory
BASE_DIR=$(pwd)

# Function to run tests with proper output handling
run_test_suite() {
  local test_name=$1
  local command=$2
  local dir=$3
  
  echo -e "\n${YELLOW}Running $test_name tests...${NC}"
  
  # Change to directory if provided
  if [ -n "$dir" ]; then
    cd "$dir" || { echo -e "${RED}Failed to change to directory $dir${NC}"; return 1; }
  fi
  
  # Run test command
  eval "$command"
  local status=$?
  
  # Return to base directory if needed
  if [ -n "$dir" ]; then
    cd "$BASE_DIR" || { echo -e "${RED}Failed to return to base directory${NC}"; return 1; }
  fi
  
  # Check test result
  if [ $status -eq 0 ]; then
    echo -e "${GREEN}✓ $test_name tests passed!${NC}"
  else
    echo -e "${RED}✗ $test_name tests failed!${NC}"
    return 1
  fi
  
  return 0
}

# Track overall test status
OVERALL_STATUS=0

# Backend Ruby tests
run_test_suite "Backend Unit" "bundle exec rails test:units" "$BASE_DIR/backend"
if [ $? -ne 0 ]; then OVERALL_STATUS=1; fi

run_test_suite "Backend Functional" "bundle exec rails test:functionals" "$BASE_DIR/backend"
if [ $? -ne 0 ]; then OVERALL_STATUS=1; fi

run_test_suite "Backend Integration" "bundle exec rails test:integration" "$BASE_DIR/backend"
if [ $? -ne 0 ]; then OVERALL_STATUS=1; fi

run_test_suite "Backend System" "bundle exec rails test:system" "$BASE_DIR/backend"
if [ $? -ne 0 ]; then OVERALL_STATUS=1; fi

# Frontend Flutter tests
run_test_suite "Frontend Widget" "flutter test" "$BASE_DIR/frontend/mobile"
if [ $? -ne 0 ]; then OVERALL_STATUS=1; fi

# Check overall status and report
echo -e "\n${YELLOW}=========================================${NC}"
if [ $OVERALL_STATUS -eq 0 ]; then
  echo -e "${GREEN}All tests passed successfully!${NC}"
else
  echo -e "${RED}Some tests failed. Please check the logs above.${NC}"
fi
echo -e "${YELLOW}=========================================${NC}"

exit $OVERALL_STATUS 
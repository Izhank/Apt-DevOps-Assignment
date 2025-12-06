import sys
import json

def get_alb_dns():
    """Reads the Terraform output JSON and prints the ALB DNS name."""
    try:
        # Terraform output is typically written to stdout, but can be captured as JSON
        # For simplicity, we assume the user has run: terraform output -json > tf_output.json
        # However, for a one-click script, reading from 'terraform output -json' is cleaner.
        import subprocess
        
        # Execute terraform output -json
        result = subprocess.run(
            ['terraform', 'output', '-json'],
            capture_output=True,
            text=True,
            check=True,
            cwd='../terraform' # Execute from the terraform directory
        )
        
        output = json.loads(result.stdout)
        
        if 'alb_dns_name' in output and 'value' in output['alb_dns_name']:
            print(output['alb_dns_name']['value'])
        else:
            sys.stderr.write("Error: 'alb_dns_name' not found in Terraform outputs.\n")
            sys.exit(1)

    except FileNotFoundError:
        sys.stderr.write("Error: Terraform command not found. Ensure it is in your PATH.\n")
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        sys.stderr.write(f"Error running 'terraform output -json': {e.stderr}\n")
        sys.exit(1)
    except json.JSONDecodeError:
        sys.stderr.write("Error: Could not decode Terraform output as JSON.\n")
        sys.exit(1)
    except Exception as e:
        sys.stderr.write(f"An unexpected error occurred: {e}\n")
        sys.exit(1)

if __name__ == '__main__':
    get_alb_dns()
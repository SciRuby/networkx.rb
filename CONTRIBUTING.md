# Contribution guidelines

First of all, thanks for thinking of contributing to this project. :smile:

Before sending a Pull Request, please make sure that you're assigned the task on a GitHub issue.

- If a relevant issue already exists, discuss on the issue and get it assigned to yourself on GitHub.
- If no relevant issue exists, open a new issue and get it assigned to yourself on GitHub.

Please proceed with a Pull Request only after you're assigned. It'd be sad if your Pull Request (and your hardwork) isn't accepted just because it isn't idealogically compatible.

# Developing the gem

1. Clone this repository and install all the required gem dependencies.

    ```sh
    git clone https://github.com/athityakumar/daru-io.git
    cd daru-io
    gem install bundler
    bundle install
    ```

2. Checkout to a different git branch (say, `adds-new-feature`).

3. Add any gem dependencies required, appropriately to the gemspec file or Gemfile.

4. Add code and YARD documentation.

5. Add tests to `spec/networkx/filename_spec.rb`. Add any files required for testing in the `spec/fixtures/` directory.

6. Run the rspec test-suite.
    ```sh
    # Runs test suite for all files
    bundle exec rspec

    # Runs test-suite only for a particular file
    bundle exec rspec spec/networkx/filename_spec.rb
    ```

7. Run the rubocop for static code quality comments.

    ```sh
    # Runs rubocop test for all files
    bundle exec rubocop

    # Runs rubocop test only for a particular file
    bundle exec rubocop lib/networkx/filename.rb
    ```

8. Send a Pull Request back to this repository. :tada:

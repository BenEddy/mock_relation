class MockRelation < Hash
  attr_reader :mocked_scopes

  def initialize(*mocked_scopes)
    @mocked_scopes = mocked_scopes
    super()
  end

  def scoped?
    any?
  end

  def scoped_by?(scope, *args)
    fetch(scope, []).include?(args)
  end

  def includes(*args)
    self
  end
  alias :joins :includes
  alias :scoped :includes

  def unscoped
    clone.clear
  end

  def destroy_all
    @destroyed = true
  end

  def destroyed?
    @destroyed
  end

  private

  def mocks_scope?(scope)
    mocked_scopes.include?(scope)
  end

  def record_invocation(scope, *args)
    clone.tap do |clone|
      clone[scope] = fetch(scope, []).push(args)
    end
  end

  def method_missing(scope, *args)
    mocks_scope?(scope) ? record_invocation(scope, *args) : super
  end
end

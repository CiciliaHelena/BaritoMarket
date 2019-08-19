# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: proto/profile.proto for package ''

require 'grpc'
require 'proto/profile_pb'

module ProfileService
  class Service

    include GRPC::GenericService

    self.marshal_class_method = :encode
    self.unmarshal_class_method = :decode
    self.service_name = 'ProfileService'

    rpc :GetProfileByClusterName, ProfileRequest, Profile
    rpc :GetProfileByAppSecret, ProfileRequest, Profile
    rpc :GetProfileByAppGroupSecret, ProfileRequest, Profile
    rpc :GetUserAuthorization, User, AuthResponse
  end

  Stub = Service.rpc_stub_class
end

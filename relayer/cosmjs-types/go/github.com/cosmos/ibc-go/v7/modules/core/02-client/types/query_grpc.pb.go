// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.3.0
// - protoc             (unknown)
// source: ibc/core/client/v1/query.proto

package types

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

const (
	Query_ClientState_FullMethodName            = "/ibc.core.client.v1.Query/ClientState"
	Query_ClientStates_FullMethodName           = "/ibc.core.client.v1.Query/ClientStates"
	Query_ConsensusState_FullMethodName         = "/ibc.core.client.v1.Query/ConsensusState"
	Query_ConsensusStates_FullMethodName        = "/ibc.core.client.v1.Query/ConsensusStates"
	Query_ConsensusStateHeights_FullMethodName  = "/ibc.core.client.v1.Query/ConsensusStateHeights"
	Query_ClientStatus_FullMethodName           = "/ibc.core.client.v1.Query/ClientStatus"
	Query_ClientParams_FullMethodName           = "/ibc.core.client.v1.Query/ClientParams"
	Query_UpgradedClientState_FullMethodName    = "/ibc.core.client.v1.Query/UpgradedClientState"
	Query_UpgradedConsensusState_FullMethodName = "/ibc.core.client.v1.Query/UpgradedConsensusState"
	Query_LatestHeight_FullMethodName           = "/ibc.core.client.v1.Query/LatestHeight"
	Query_NewClient_FullMethodName              = "/ibc.core.client.v1.Query/NewClient"
	Query_BlockData_FullMethodName              = "/ibc.core.client.v1.Query/BlockData"
)

// QueryClient is the client API for Query service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type QueryClient interface {
	// ClientState queries an IBC light client.
	ClientState(ctx context.Context, in *QueryClientStateRequest, opts ...grpc.CallOption) (*QueryClientStateResponse, error)
	// ClientStates queries all the IBC light clients of a chain.
	ClientStates(ctx context.Context, in *QueryClientStatesRequest, opts ...grpc.CallOption) (*QueryClientStatesResponse, error)
	// ConsensusState queries a consensus state associated with a client state at
	// a given height.
	ConsensusState(ctx context.Context, in *QueryConsensusStateRequest, opts ...grpc.CallOption) (*QueryConsensusStateResponse, error)
	// ConsensusStates queries all the consensus state associated with a given
	// client.
	ConsensusStates(ctx context.Context, in *QueryConsensusStatesRequest, opts ...grpc.CallOption) (*QueryConsensusStatesResponse, error)
	// ConsensusStateHeights queries the height of every consensus states associated with a given client.
	ConsensusStateHeights(ctx context.Context, in *QueryConsensusStateHeightsRequest, opts ...grpc.CallOption) (*QueryConsensusStateHeightsResponse, error)
	// Status queries the status of an IBC client.
	ClientStatus(ctx context.Context, in *QueryClientStatusRequest, opts ...grpc.CallOption) (*QueryClientStatusResponse, error)
	// ClientParams queries all parameters of the ibc client submodule.
	ClientParams(ctx context.Context, in *QueryClientParamsRequest, opts ...grpc.CallOption) (*QueryClientParamsResponse, error)
	// UpgradedClientState queries an Upgraded IBC light client.
	UpgradedClientState(ctx context.Context, in *QueryUpgradedClientStateRequest, opts ...grpc.CallOption) (*QueryUpgradedClientStateResponse, error)
	// UpgradedConsensusState queries an Upgraded IBC consensus state.
	UpgradedConsensusState(ctx context.Context, in *QueryUpgradedConsensusStateRequest, opts ...grpc.CallOption) (*QueryUpgradedConsensusStateResponse, error)
	LatestHeight(ctx context.Context, in *QueryLatestHeightRequest, opts ...grpc.CallOption) (*QueryLatestHeightResponse, error)
	NewClient(ctx context.Context, in *QueryNewClientRequest, opts ...grpc.CallOption) (*QueryNewClientResponse, error)
	BlockData(ctx context.Context, in *QueryBlockDataRequest, opts ...grpc.CallOption) (*QueryBlockDataResponse, error)
}

type queryClient struct {
	cc grpc.ClientConnInterface
}

func NewQueryClient(cc grpc.ClientConnInterface) QueryClient {
	return &queryClient{cc}
}

func (c *queryClient) ClientState(ctx context.Context, in *QueryClientStateRequest, opts ...grpc.CallOption) (*QueryClientStateResponse, error) {
	out := new(QueryClientStateResponse)
	err := c.cc.Invoke(ctx, Query_ClientState_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) ClientStates(ctx context.Context, in *QueryClientStatesRequest, opts ...grpc.CallOption) (*QueryClientStatesResponse, error) {
	out := new(QueryClientStatesResponse)
	err := c.cc.Invoke(ctx, Query_ClientStates_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) ConsensusState(ctx context.Context, in *QueryConsensusStateRequest, opts ...grpc.CallOption) (*QueryConsensusStateResponse, error) {
	out := new(QueryConsensusStateResponse)
	err := c.cc.Invoke(ctx, Query_ConsensusState_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) ConsensusStates(ctx context.Context, in *QueryConsensusStatesRequest, opts ...grpc.CallOption) (*QueryConsensusStatesResponse, error) {
	out := new(QueryConsensusStatesResponse)
	err := c.cc.Invoke(ctx, Query_ConsensusStates_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) ConsensusStateHeights(ctx context.Context, in *QueryConsensusStateHeightsRequest, opts ...grpc.CallOption) (*QueryConsensusStateHeightsResponse, error) {
	out := new(QueryConsensusStateHeightsResponse)
	err := c.cc.Invoke(ctx, Query_ConsensusStateHeights_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) ClientStatus(ctx context.Context, in *QueryClientStatusRequest, opts ...grpc.CallOption) (*QueryClientStatusResponse, error) {
	out := new(QueryClientStatusResponse)
	err := c.cc.Invoke(ctx, Query_ClientStatus_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) ClientParams(ctx context.Context, in *QueryClientParamsRequest, opts ...grpc.CallOption) (*QueryClientParamsResponse, error) {
	out := new(QueryClientParamsResponse)
	err := c.cc.Invoke(ctx, Query_ClientParams_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) UpgradedClientState(ctx context.Context, in *QueryUpgradedClientStateRequest, opts ...grpc.CallOption) (*QueryUpgradedClientStateResponse, error) {
	out := new(QueryUpgradedClientStateResponse)
	err := c.cc.Invoke(ctx, Query_UpgradedClientState_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) UpgradedConsensusState(ctx context.Context, in *QueryUpgradedConsensusStateRequest, opts ...grpc.CallOption) (*QueryUpgradedConsensusStateResponse, error) {
	out := new(QueryUpgradedConsensusStateResponse)
	err := c.cc.Invoke(ctx, Query_UpgradedConsensusState_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) LatestHeight(ctx context.Context, in *QueryLatestHeightRequest, opts ...grpc.CallOption) (*QueryLatestHeightResponse, error) {
	out := new(QueryLatestHeightResponse)
	err := c.cc.Invoke(ctx, Query_LatestHeight_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) NewClient(ctx context.Context, in *QueryNewClientRequest, opts ...grpc.CallOption) (*QueryNewClientResponse, error) {
	out := new(QueryNewClientResponse)
	err := c.cc.Invoke(ctx, Query_NewClient_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

func (c *queryClient) BlockData(ctx context.Context, in *QueryBlockDataRequest, opts ...grpc.CallOption) (*QueryBlockDataResponse, error) {
	out := new(QueryBlockDataResponse)
	err := c.cc.Invoke(ctx, Query_BlockData_FullMethodName, in, out, opts...)
	if err != nil {
		return nil, err
	}
	return out, nil
}

// QueryServer is the server API for Query service.
// All implementations must embed UnimplementedQueryServer
// for forward compatibility
type QueryServer interface {
	// ClientState queries an IBC light client.
	ClientState(context.Context, *QueryClientStateRequest) (*QueryClientStateResponse, error)
	// ClientStates queries all the IBC light clients of a chain.
	ClientStates(context.Context, *QueryClientStatesRequest) (*QueryClientStatesResponse, error)
	// ConsensusState queries a consensus state associated with a client state at
	// a given height.
	ConsensusState(context.Context, *QueryConsensusStateRequest) (*QueryConsensusStateResponse, error)
	// ConsensusStates queries all the consensus state associated with a given
	// client.
	ConsensusStates(context.Context, *QueryConsensusStatesRequest) (*QueryConsensusStatesResponse, error)
	// ConsensusStateHeights queries the height of every consensus states associated with a given client.
	ConsensusStateHeights(context.Context, *QueryConsensusStateHeightsRequest) (*QueryConsensusStateHeightsResponse, error)
	// Status queries the status of an IBC client.
	ClientStatus(context.Context, *QueryClientStatusRequest) (*QueryClientStatusResponse, error)
	// ClientParams queries all parameters of the ibc client submodule.
	ClientParams(context.Context, *QueryClientParamsRequest) (*QueryClientParamsResponse, error)
	// UpgradedClientState queries an Upgraded IBC light client.
	UpgradedClientState(context.Context, *QueryUpgradedClientStateRequest) (*QueryUpgradedClientStateResponse, error)
	// UpgradedConsensusState queries an Upgraded IBC consensus state.
	UpgradedConsensusState(context.Context, *QueryUpgradedConsensusStateRequest) (*QueryUpgradedConsensusStateResponse, error)
	LatestHeight(context.Context, *QueryLatestHeightRequest) (*QueryLatestHeightResponse, error)
	NewClient(context.Context, *QueryNewClientRequest) (*QueryNewClientResponse, error)
	BlockData(context.Context, *QueryBlockDataRequest) (*QueryBlockDataResponse, error)
	mustEmbedUnimplementedQueryServer()
}

// UnimplementedQueryServer must be embedded to have forward compatible implementations.
type UnimplementedQueryServer struct {
}

func (UnimplementedQueryServer) ClientState(context.Context, *QueryClientStateRequest) (*QueryClientStateResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method ClientState not implemented")
}
func (UnimplementedQueryServer) ClientStates(context.Context, *QueryClientStatesRequest) (*QueryClientStatesResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method ClientStates not implemented")
}
func (UnimplementedQueryServer) ConsensusState(context.Context, *QueryConsensusStateRequest) (*QueryConsensusStateResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method ConsensusState not implemented")
}
func (UnimplementedQueryServer) ConsensusStates(context.Context, *QueryConsensusStatesRequest) (*QueryConsensusStatesResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method ConsensusStates not implemented")
}
func (UnimplementedQueryServer) ConsensusStateHeights(context.Context, *QueryConsensusStateHeightsRequest) (*QueryConsensusStateHeightsResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method ConsensusStateHeights not implemented")
}
func (UnimplementedQueryServer) ClientStatus(context.Context, *QueryClientStatusRequest) (*QueryClientStatusResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method ClientStatus not implemented")
}
func (UnimplementedQueryServer) ClientParams(context.Context, *QueryClientParamsRequest) (*QueryClientParamsResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method ClientParams not implemented")
}
func (UnimplementedQueryServer) UpgradedClientState(context.Context, *QueryUpgradedClientStateRequest) (*QueryUpgradedClientStateResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method UpgradedClientState not implemented")
}
func (UnimplementedQueryServer) UpgradedConsensusState(context.Context, *QueryUpgradedConsensusStateRequest) (*QueryUpgradedConsensusStateResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method UpgradedConsensusState not implemented")
}
func (UnimplementedQueryServer) LatestHeight(context.Context, *QueryLatestHeightRequest) (*QueryLatestHeightResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method LatestHeight not implemented")
}
func (UnimplementedQueryServer) NewClient(context.Context, *QueryNewClientRequest) (*QueryNewClientResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method NewClient not implemented")
}
func (UnimplementedQueryServer) BlockData(context.Context, *QueryBlockDataRequest) (*QueryBlockDataResponse, error) {
	return nil, status.Errorf(codes.Unimplemented, "method BlockData not implemented")
}
func (UnimplementedQueryServer) mustEmbedUnimplementedQueryServer() {}

// UnsafeQueryServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to QueryServer will
// result in compilation errors.
type UnsafeQueryServer interface {
	mustEmbedUnimplementedQueryServer()
}

func RegisterQueryServer(s grpc.ServiceRegistrar, srv QueryServer) {
	s.RegisterService(&Query_ServiceDesc, srv)
}

func _Query_ClientState_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryClientStateRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).ClientState(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_ClientState_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).ClientState(ctx, req.(*QueryClientStateRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_ClientStates_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryClientStatesRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).ClientStates(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_ClientStates_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).ClientStates(ctx, req.(*QueryClientStatesRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_ConsensusState_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryConsensusStateRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).ConsensusState(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_ConsensusState_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).ConsensusState(ctx, req.(*QueryConsensusStateRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_ConsensusStates_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryConsensusStatesRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).ConsensusStates(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_ConsensusStates_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).ConsensusStates(ctx, req.(*QueryConsensusStatesRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_ConsensusStateHeights_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryConsensusStateHeightsRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).ConsensusStateHeights(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_ConsensusStateHeights_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).ConsensusStateHeights(ctx, req.(*QueryConsensusStateHeightsRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_ClientStatus_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryClientStatusRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).ClientStatus(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_ClientStatus_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).ClientStatus(ctx, req.(*QueryClientStatusRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_ClientParams_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryClientParamsRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).ClientParams(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_ClientParams_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).ClientParams(ctx, req.(*QueryClientParamsRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_UpgradedClientState_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryUpgradedClientStateRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).UpgradedClientState(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_UpgradedClientState_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).UpgradedClientState(ctx, req.(*QueryUpgradedClientStateRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_UpgradedConsensusState_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryUpgradedConsensusStateRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).UpgradedConsensusState(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_UpgradedConsensusState_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).UpgradedConsensusState(ctx, req.(*QueryUpgradedConsensusStateRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_LatestHeight_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryLatestHeightRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).LatestHeight(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_LatestHeight_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).LatestHeight(ctx, req.(*QueryLatestHeightRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_NewClient_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryNewClientRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).NewClient(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_NewClient_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).NewClient(ctx, req.(*QueryNewClientRequest))
	}
	return interceptor(ctx, in, info, handler)
}

func _Query_BlockData_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(QueryBlockDataRequest)
	if err := dec(in); err != nil {
		return nil, err
	}
	if interceptor == nil {
		return srv.(QueryServer).BlockData(ctx, in)
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: Query_BlockData_FullMethodName,
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(QueryServer).BlockData(ctx, req.(*QueryBlockDataRequest))
	}
	return interceptor(ctx, in, info, handler)
}

// Query_ServiceDesc is the grpc.ServiceDesc for Query service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var Query_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "ibc.core.client.v1.Query",
	HandlerType: (*QueryServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "ClientState",
			Handler:    _Query_ClientState_Handler,
		},
		{
			MethodName: "ClientStates",
			Handler:    _Query_ClientStates_Handler,
		},
		{
			MethodName: "ConsensusState",
			Handler:    _Query_ConsensusState_Handler,
		},
		{
			MethodName: "ConsensusStates",
			Handler:    _Query_ConsensusStates_Handler,
		},
		{
			MethodName: "ConsensusStateHeights",
			Handler:    _Query_ConsensusStateHeights_Handler,
		},
		{
			MethodName: "ClientStatus",
			Handler:    _Query_ClientStatus_Handler,
		},
		{
			MethodName: "ClientParams",
			Handler:    _Query_ClientParams_Handler,
		},
		{
			MethodName: "UpgradedClientState",
			Handler:    _Query_UpgradedClientState_Handler,
		},
		{
			MethodName: "UpgradedConsensusState",
			Handler:    _Query_UpgradedConsensusState_Handler,
		},
		{
			MethodName: "LatestHeight",
			Handler:    _Query_LatestHeight_Handler,
		},
		{
			MethodName: "NewClient",
			Handler:    _Query_NewClient_Handler,
		},
		{
			MethodName: "BlockData",
			Handler:    _Query_BlockData_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "ibc/core/client/v1/query.proto",
}
//
//  UAGithubEngine.m
//  UAGithubEngine
//
//  Created by Owain Hunt on 02/04/2010.
//  Copyright 2010 Owain R Hunt. All rights reserved.
//

#import "UAGithubEngine.h"
#import "UAGithubEngineRequestTypes.h"
#import "UAGithubRepositoriesParser.h"
#import "UAGithubIssuesParser.h"
#import "UAGithubIssueCommentsParser.h"
#import "UAGithubIssueLabelsParser.h"
#import "UAGithubRepositoryLabelsParser.h"
#import "UAGithubUsersParser.h"
#import "UAGithubCommitsParser.h"
#import "UAGithubBlobParser.h"
#import "UAGithubCollaboratorsParser.h"
#import "UAGithubURLConnection.h"

#import "CJSONDeserializer.h"


@interface UAGithubEngine (Private)

- (NSString *)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(NSDictionary *)params;


@end


@implementation UAGithubEngine

@synthesize delegate, username, apiKey, dataFormat, connections;


#pragma mark Initializer


- (id)initWithUsername:(NSString *)aUsername apiKey:(NSString *)aKey delegate:(id)theDelegate
{
	if (self = [super init]) 
	{
		username = [aUsername retain];
		apiKey = [aKey retain];
		delegate = theDelegate;
		//dataFormat = @"xml";
        dataFormat = @"json";
		connections = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	
	return self;
		
}


- (void)dealloc
{
	[username release];
	[apiKey release];
	[dataFormat release];
	[connections release];
	delegate = nil;
	
	[super dealloc];
	
}


- (NSString *)sendRequest:(NSString *)path requestType:(UAGithubRequestType)requestType responseType:(UAGithubResponseType)responseType withParameters:(NSDictionary *)params
{
	
	NSMutableString *querystring = nil;
	if (![params isEqual:nil]) 
	{
		querystring = [NSMutableString stringWithCapacity:0];
		for (NSString *key in [params allKeys]) 
		{
			[querystring appendFormat:@"&%@=%@", key, [[params valueForKey:key] encodedString]];
		}
	}
	
	NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://github.com/api/v2/%@/%@?login=%@&token=%@", self.dataFormat, path, self.username, self.apiKey];
	if (![querystring isEqual:nil])
	{
		[urlString appendString:querystring];
	}
	
	NSURL *theURL = [NSURL URLWithString:urlString];
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
	UAGithubURLConnection *connection;
	connection = [[UAGithubURLConnection alloc] initWithRequest:urlRequest delegate:self requestType:requestType responseType:responseType];
	
	if (!connection) 
	{
		return nil;
	}
	else
	{ 
		[connections setObject:connection forKey:connection.identifier];
		[connection release];
	}
	
	return connection.identifier;
	
}


- (void)parseDataForConnection:(UAGithubURLConnection *)connection
{
    /*
	switch (connection.responseType) {
		case UAGithubRepositoriesResponse:
		case UAGithubRepositoryResponse:
			[[UAGithubRepositoriesParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubIssuesResponse:
		case UAGithubIssueResponse:
			[[UAGithubIssuesParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubCommentsResponse:
		case UAGithubCommentResponse:
			[[UAGithubIssueCommentsParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubUsersResponse:
		case UAGithubUserResponse:
			[[UAGithubUsersParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubLabelsResponse:
			[[UAGithubIssueLabelsParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubRepositoryLabelsResponse:
			[[UAGithubRepositoryLabelsParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubCommitsResponse:
		case UAGithubCommitResponse:
			[[UAGithubCommitsParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubBlobsResponse:
			break;
		case UAGithubBlobResponse:
			[[UAGithubBlobParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		case UAGithubRawBlobResponse:
			[delegate rawBlobReceived:connection.data forConnection:connection.identifier];
			break;
		case UAGithubCollaboratorsResponse:
			[[UAGithubCollaboratorsParser alloc] initWithXML:connection.data delegate:self connectionIdentifier:connection.identifier requestType:connection.requestType responseType:connection.responseType];
			break;
		default:
			break;
	}
     */
    //NSData *jsonData = [connection.data dataUsingEncoding:NSUTF32BigEndianStringEncoding]; 
    NSError *error = nil; 
    NSLog(@"%@", [[CJSONDeserializer deserializer] deserializeAsDictionary:connection.data error:&error]);
}
	

#pragma mark Parser Delegate Methods

- (void)parsingSucceededForConnection:(NSString *)connectionIdentifier ofResponseType:(UAGithubResponseType)responseType withParsedObjects:(NSArray *)parsedObjects
{
	
	switch (responseType) {
		case UAGithubRepositoriesResponse:
		case UAGithubRepositoryResponse:
			[delegate repositoriesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubIssuesResponse:
		case UAGithubIssueResponse:
			[delegate issuesReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubCommentsResponse:
		case UAGithubCommentResponse:
			[delegate issueCommentsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubUsersResponse:
		case UAGithubUserResponse:
			[delegate usersReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubLabelsResponse:
		case UAGithubRepositoryLabelsResponse:
			[delegate labelsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubCommitsResponse:
		case UAGithubCommitResponse:
			[delegate commitsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubBlobsResponse:
			[delegate blobsReceieved:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubBlobResponse:
			[delegate blobReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		case UAGithubCollaboratorsResponse:
			[delegate collaboratorsReceived:parsedObjects forConnection:connectionIdentifier];
			break;
		default:
			break;
	}
	//[NSApp terminate:self];
	
	
}


- (void)parsingFailedForConnection:(NSString *)connectionIdentifier ofResponseType:(UAGithubResponseType)responseType withError:(NSError *)parseError
{
	[delegate requestFailed:connectionIdentifier withError:parseError];
	
}


#pragma mark Repositories

- (void)getRepositoriesForUser:(NSString *)aUser includeWatched:(BOOL)watched
{
	[self sendRequest:[NSString stringWithFormat:@"repos/%@/%@", (watched ? @"watched" : @"show"), aUser] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];
	
}


- (void)getRepository:(NSString *)repositoryPath;
{
	[self sendRequest:[NSString stringWithFormat:@"repos/show/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:nil];
	
}


- (void)searchRepositories:(NSString *)query
{
	[self sendRequest:[NSString stringWithFormat:@"repos/search/%@", [query encodedString]] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];
	 
}


- (void)updateRepository:(NSString *)repositoryPath withInfo:(NSDictionary *)infoDictionary
{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	for (NSString *key in [infoDictionary allKeys])
	{
		[params setObject:[infoDictionary objectForKey:key] forKey:[NSString stringWithFormat:@"values[%@]", key]];
		
	}
	
	[self sendRequest:[NSString stringWithFormat:@"repos/show/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:params];
	
}


- (void)watchRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"repos/watch/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:nil];
	 
}


- (void)unwatchRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"repos/unwatch/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:nil];

}


- (void)forkRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"repos/fork/%@", repositoryPath] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:nil];

}


- (void)createRepositoryWithInfo:(NSDictionary *)infoDictionary
{
	[self sendRequest:@"repos/create" requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:nil];
	
}


- (void)deleteRepository:(NSString *)repositoryName
{
	[self sendRequest:[NSString stringWithFormat:@"repos/delete/%@", repositoryName] requestType:UAGithubDeleteRepositoryRequest responseType:UAGithubDeleteRepositoryResponse withParameters:nil];

}


- (void)confirmDeletionOfRepository:(NSString *)repositoryName withToken:(NSString *)deleteToken
{
	NSDictionary *params = [NSDictionary dictionaryWithObject:deleteToken forKey:@"delete_token"];
	[self sendRequest:[NSString stringWithFormat:@"repos/delete/%@", repositoryName] requestType:UAGithubDeleteRepositoryConfirmationRequest responseType:UAGithubDeleteRepositoryConfirmationResponse withParameters:params];
	
}


- (void)privatiseRepository:(NSString *)repositoryName
{
	[self sendRequest:[NSString stringWithFormat:@"repos/set/private/%@", repositoryName] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:nil];
	
}


- (void)publiciseRepository:(NSString *)repositoryName
{
	[self sendRequest:[NSString stringWithFormat:@"repos/set/public/%@", repositoryName] requestType:UAGithubRepositoryRequest responseType:UAGithubRepositoryResponse withParameters:nil];

}


- (void)getDeployKeysForRepository:(NSString *)repositoryName
{
	[self sendRequest:[NSString stringWithFormat:@"repos/keys/%@", repositoryName] requestType:UAGithubDeployKeysRequest responseType:UAGithubDeployKeysResponse withParameters:nil];

}


- (void)addDeployKey:(NSString *)keyData withTitle:(NSString *)keyTitle ToRepository:(NSString *)repositoryName
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:keyData, @"key", keyTitle, @"title", nil];
	[self sendRequest:[NSString stringWithFormat:@"repos/keys/%@/add", repositoryName] requestType:UAGithubDeployKeysRequest responseType:UAGithubDeployKeysResponse withParameters:params];

}


- (void)removeDeployKey:(NSString *)keyID fromRepository:(NSString *)repositoryName
{
	NSDictionary *params = [NSDictionary dictionaryWithObject:keyID forKey:@"id"];
	[self sendRequest:[NSString stringWithFormat:@"repos/keys/%@/remove", repositoryName] requestType:UAGithubDeployKeysRequest responseType:UAGithubDeployKeysResponse withParameters:params];

}


- (void)getCollaboratorsForRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"repos/show/%@/collaborators", repositoryPath] requestType:UAGithubCollaboratorsRequest responseType:UAGithubCollaboratorsResponse withParameters:nil];
	
}


- (void)addCollaborator:(NSString *)collaborator toRepository:(NSString *)repositoryName
{
	[self sendRequest:[NSString stringWithFormat:@"repos/collaborators/%@/add/%@", repositoryName, collaborator] requestType:UAGithubCollaboratorsRequest responseType:UAGithubCollaboratorsResponse withParameters:nil];

}


- (void)removeCollaborator:(NSString *)collaborator fromRepository:(NSString *)repositoryName
{
	[self sendRequest:[NSString stringWithFormat:@"repos/collaborators/%@/remove/%@", repositoryName, collaborator] requestType:UAGithubCollaboratorsRequest responseType:UAGithubCollaboratorsResponse withParameters:nil];

}


- (void)getPushableRepositories
{
	[self sendRequest:@"repos/pushable" requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];
	
}


- (void)getNetworkForRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"repos/show/%@/network", repositoryPath] requestType:UAGithubRepositoriesRequest responseType:UAGithubRepositoriesResponse withParameters:nil];
	
}


- (void)getLanguageBreakdownForRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"repos/show/%@/languages", repositoryPath] requestType:UAGithubLanguagesRequest responseType:UAGithubLanguagesResponse withParameters:nil];
	
}


- (void)getTagsForRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"repos/show/%@/tags", repositoryPath] requestType:UAGithubTagsRequest responseType:UAGithubTagsResponse withParameters:nil];
	
}


- (void)getBranchesForRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"repos/show/%@/branches", repositoryPath] requestType:UAGithubBranchesRequest responseType:UAGithubBranchesResponse withParameters:nil];
	
}


#pragma mark Issues 

- (void)getIssuesForRepository:(NSString *)repositoryPath withRequestType:(UAGithubRequestType)requestType
{
	switch (requestType) {
		case UAGithubAllIssuesRequest:
			[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/open", repositoryPath] requestType:UAGithubIssuesRequest responseType:UAGithubIssuesResponse withParameters:nil];
			[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/closed", repositoryPath] requestType:UAGithubIssuesRequest responseType:UAGithubIssuesResponse withParameters:nil];
			break;
		case UAGithubOpenIssuesRequest:
			[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/open", repositoryPath] requestType:UAGithubIssuesRequest responseType:UAGithubIssuesResponse withParameters:nil];
			break;
		case UAGithubClosedIssuesRequest:
			[self sendRequest:[NSString stringWithFormat:@"issues/list/%@/closed", repositoryPath] requestType:UAGithubIssuesRequest responseType:UAGithubIssuesResponse withParameters:nil];
			break;
		default:
			break;
	}
	
}


- (void)getIssue:(NSString *)issuePath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/show/%@", issuePath] requestType:UAGithubIssueRequest responseType:UAGithubIssueResponse withParameters:nil];
	
}


- (void)editIssue:(NSString *)issuePath withDictionary:(NSDictionary *)issueDictionary
{
	[self sendRequest:[NSString stringWithFormat:@"issues/edit/%@", issuePath] requestType:UAGithubEditIssueRequest responseType:UAGithubIssueResponse withParameters:issueDictionary];
	
}


- (void)addIssueForRepository:(NSString *)repositoryPath withDictionary:(NSDictionary *)issueDictionary
{
	[self sendRequest:[NSString stringWithFormat:@"issues/open/%@", repositoryPath] requestType:UAGithubAddIssueRequest responseType:UAGithubIssueResponse withParameters:issueDictionary];
	
}


- (void)closeIssue:(NSString *)issuePath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/close/%@", issuePath] requestType:UAGithubCloseIssueRequest responseType:UAGithubIssueResponse withParameters:nil];
	
}


- (void)reopenIssue:(NSString *)issuePath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/reopen/%@", issuePath] requestType:UAGithubReopenIssueRequest responseType:UAGithubIssueResponse withParameters:nil];
	
}


#pragma mark Labels

- (void)getLabelsForRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/labels/%@", repositoryPath] requestType:UAGithubRepositoryLabelsRequest responseType:UAGithubRepositoryLabelsResponse withParameters:nil];
	
}


- (void)addLabel:(NSString *)label toRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/label/add/%@/%@", repositoryPath, [label encodedString]] requestType:UAGithubAddLabelRequest responseType:UAGithubLabelsResponse withParameters:nil];
	
}


- (void)removeLabel:(NSString *)label fromRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/label/remove/%@/%@", repositoryPath, [label encodedString]] requestType:UAGithubRemoveLabelRequest responseType:UAGithubLabelsResponse withParameters:nil];
	
	
}


- (void)addLabel:(NSString *)label toIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/label/add/%@/%@/%d", repositoryPath, [label encodedString], issueNumber] requestType:UAGithubAddLabelRequest responseType:UAGithubLabelsResponse withParameters:nil];
	
}


- (void)removeLabel:(NSString *)label fromIssue:(NSInteger)issueNumber inRepository:(NSString *)repositoryPath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/label/remove/%@/%@/%d", repositoryPath, [label encodedString], issueNumber] requestType:UAGithubRemoveLabelRequest responseType:UAGithubLabelsResponse withParameters:nil];
	
}


#pragma mark Comments

- (void)getCommentsForIssue:(NSString *)issuePath
{
	[self sendRequest:[NSString stringWithFormat:@"issues/comments/%@", issuePath] requestType:UAGithubCommentsRequest responseType:UAGithubCommentsResponse withParameters:nil];
	
}


- (void)addComment:(NSString *)comment toIssue:(NSString *)issuePath
{
	NSDictionary *commentDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"comment"];
	[self sendRequest:[NSString stringWithFormat:@"issues/comment/%@", issuePath] requestType:UAGithubAddCommentRequest responseType:UAGithubCommentResponse withParameters:commentDictionary];
	
}


#pragma mark Users

- (void)getUser:(NSString *)user
{
	[self sendRequest:[NSString stringWithFormat:@"user/show/%@", user] requestType:UAGithubUserRequest responseType:UAGithubUserResponse withParameters:nil];
	
}


#pragma mark Commits

- (void)getCommitsForBranch:(NSString *)branchPath
{
	[self sendRequest:[NSString stringWithFormat:@"commits/list/%@", branchPath] requestType:UAGithubCommitsRequest responseType:UAGithubCommitsResponse withParameters:nil];
	
}


- (void)getCommit:(NSString *)commitPath
{
	[self sendRequest:[NSString stringWithFormat:@"commits/show/%@", commitPath] requestType:UAGithubCommitRequest responseType:UAGithubCommitResponse withParameters:nil];
	
}
	

#pragma mark Trees

- (void)getTree:(NSString *)treePath
{
	[self sendRequest:[NSString stringWithFormat:@"tree/show/%@", treePath] requestType:UAGithubTreeRequest responseType:UAGithubTreeResponse withParameters:nil];
	
}


#pragma mark Blobs

- (void)getBlobsForSHA:(NSString *)shaPath
{
	[self sendRequest:[NSString stringWithFormat:@"blob/all/%@", shaPath] requestType:UAGithubBlobsRequest responseType:UAGithubBlobsResponse withParameters:nil];
	
}


- (void)getBlob:(NSString *)blobPath
{
	[self sendRequest:[NSString stringWithFormat:@"blob/show/%@", blobPath] requestType:UAGithubBlobRequest responseType:UAGithubBlobResponse withParameters:nil];
	
}


- (void)getRawBlob:(NSString *)blobPath
{
	[self sendRequest:[NSString stringWithFormat:@"blob/show/%@", blobPath] requestType:UAGithubRawBlobRequest responseType:UAGithubRawBlobResponse withParameters:nil];
	
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(UAGithubURLConnection *)connection didFailWithError:(NSError *)error
{
	
}


- (void)connection:(UAGithubURLConnection *)connection didReceiveData:(NSData *)data
{
	[connection appendData:data];
	
}


- (void)connection:(UAGithubURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
}


- (void)connectionDidFinishLoading:(UAGithubURLConnection *)connection
{
	[self parseDataForConnection:connection];
	
}


@end

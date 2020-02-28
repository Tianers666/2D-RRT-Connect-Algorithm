%%�������ã�Ϊ���������һ���ڵ㣬������extendFail=0��Ϊ��־����ʾ����չ��ɻ����ҵ������յ�
function [RRTree,pathFound,extendFail] = rrtExtend(RRTreeA,RRTreeB,qgoal,stepsize,maxFailedAttempts,disTh,map)
pathFound=[]; 
failedAttempts=0;
Index = RRTreeA(1,3);
while failedAttempts <= maxFailedAttempts
    if Index == 0 %%********************************��չRRTree1�ķ�ʽ************************************
        %% ��ȡ���������
        if rand < 0.5
            sample = rand(1,2) .* size(map);
        else
            sample = qgoal;  % sample taken as goal to bias tree generation to goal
        end
        %% �ҵ�������������������Ľڵ�
        [A, I] = min( distanceCost(RRTreeA(:,1:2),sample) ,[],1); 
        closestNode = RRTreeA(I(1),:);
        %% ��qnearest��qrand��չһ�ξ��뵽��xnew����������ײ���
        theta = atan2((sample(1)-closestNode(1)),(sample(2)-closestNode(2)));  % direction to extend sample to produce new node
        newPoint = double(int32(closestNode(1:2) + stepsize * [sin(theta)  cos(theta)]));
        if ~checkPath(closestNode(1:2), newPoint, map) % if extension of closest node in tree to the new point is feasible
            failedAttempts = failedAttempts + 1;
            continue;
        end
        %% ����½ڵ�����һ�����Ľڵ��Ƿ�������ֵ
        [A, I2] = min( distanceCost(RRTreeB(:,1:2),newPoint) ,[],1); 
        if distanceCost(RRTreeB(I2(1),1:2),newPoint) < disTh         
            %% ����������������߶�֮���Ƿ�����ϰ���
            if  checkPath(RRTreeB(I2(1),1:2), newPoint, map)
                pathFound = [newPoint I I2];
                extendFail = 0;
                RRTree = RRTreeA;
                break;
            else
                failedAttempts = failedAttempts + 1;
                continue;
            end
        end
        %% ����½ڵ��Ƿ��Ѿ������д���
        [A, I3] = min( distanceCost(RRTreeA(:,1:2),newPoint) ,[],1); 
        if distanceCost(newPoint,RRTreeA(I3(1),1:2)) < disTh 
            failedAttempts=failedAttempts+1;
            continue; 
        end
        RRTree = [RRTreeA;newPoint I];
        extendFail = 0;
    else %%********************************��չRRTree2�ķ�ʽ************************************
        %% ��ȡ���������
        if rand < 0.5
            sample = rand(1,2) .* size(map);
        else
            sample = qgoal;  % sample taken as goal to bias tree generation to goal
        end
        %% �ҵ�������������������Ľڵ�
        [A, I] = min( distanceCost(RRTreeA(:,1:2),sample) ,[],1);% find the minimum value of each column
        closestNode = RRTreeA(I(1),:);
        %% ��qnearest��qrand��չһ�ξ��뵽��xnew����������ײ���
        theta = atan2((sample(1)-closestNode(1)),(sample(2)-closestNode(2)));  % direction to extend sample to produce new node
        newPoint = double(int32(closestNode(1:2) + stepsize * [sin(theta)  cos(theta)]));
        if ~checkPath(closestNode(1:2), newPoint, map) % if extension of closest node in tree to the new point is feasible
            failedAttempts = failedAttempts + 1;
            continue;
        end
        RRTreeA = [RRTreeA;newPoint I];%%�ȴ�������
        line([RRTreeA(end,2);RRTreeA(RRTreeA(end,3),2)],[RRTreeA(end,1);RRTreeA(RRTreeA(end,3),1)],'color','r','linewidth',3);
        [A, I2] = min( distanceCost(RRTreeB(:,1:2),newPoint) ,[],1); 
        if distanceCost(RRTreeB(I2,1:2),newPoint) < disTh
            extendFail = 0;
            break;
        end
        flag = 1;
        while flag == 1
            Temp = newPoint;
            newPoint = double(int32(Temp(1:2) + stepsize * [sin(theta)  cos(theta)]));
            I = size(RRTreeA,1);
           %% ����½ڵ�����һ�����Ľڵ��Ƿ�������ֵ
            [A, I2] = min( distanceCost(RRTreeB(:,1:2),newPoint) ,[],1); 
            if distanceCost(RRTreeB(I2,1:2),newPoint) < disTh  
                %% ����������������߶�֮���Ƿ�����ϰ���
                if  checkPath(RRTreeB(I2,1:2), newPoint, map)
                    pathFound= [newPoint I I2];
                    extendFail = 0;
                    RRTreeA = [RRTreeA;newPoint I];
                    RRTree = RRTreeA;
                    line([RRTree(end,2);RRTree(RRTree(end,3),2)],[RRTree(end,1);RRTree(RRTree(end,3),1)],'color','r','linewidth',3);
                    break;
                else
                    break;
                end
            else
                if  ~checkPath(Temp, newPoint, map)  %%�������ײ
                    RRTree = RRTreeA;
                    extendFail = 0;
                    break;
                else
                     RRTreeA = [RRTreeA;newPoint I];
                     RRTree = RRTreeA;
                     extendFail = 0;
                     line([RRTree(end,2);RRTree(RRTree(end,3),2)],[RRTree(end,1);RRTree(RRTree(end,3),1)],'color','r','linewidth',3);
                end  
            end
        end   
    end
    break;
end

